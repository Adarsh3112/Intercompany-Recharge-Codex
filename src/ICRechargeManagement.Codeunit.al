codeunit 50100 "ICR Management"
{
    procedure ValidateRequest(var Request: Record "ICR Request Header")
    var
        PartnerSetup: Record "ICR Partner Setup";
        RequestLine: Record "ICR Request Line";
        TotalAmount: Decimal;
        TotalPercent: Decimal;
        HasLines: Boolean;
    begin
        Request.TestField("Request No.");
        Request.TestField("Partner Code");
        Request.TestField("Source Amount");
        Request.TestField("Posting Date");

        if not PartnerSetup.Get(Request."Partner Code") then
            RaiseException(Request."Request No.", 0, "ICR Exception Type"::Mapping, 'Missing intercompany partner setup.');

        if PartnerSetup.Blocked then
            Error('Partner %1 is blocked for recharge processing.', Request."Partner Code");

        PartnerSetup.TestField("Target Company");
        PartnerSetup.TestField("Source G/L Account");
        PartnerSetup.TestField("Target IC G/L Account");

        if Request."Recharge Type" = '' then
            Request."Recharge Type" := PartnerSetup."Recharge Type";
        if Request."Target Currency Code" = '' then
            Request."Target Currency Code" := PartnerSetup."Currency Code";
        if Request."Approval Threshold" = 0 then
            Request."Approval Threshold" := PartnerSetup."Approval Threshold";

        if (PartnerSetup."Currency Rule" in [PartnerSetup."Currency Rule"::"Exchange Rate Required", PartnerSetup."Currency Rule"::"Manual Rate"]) and
           (Request."Exchange Rate" = 0)
        then
            RaiseException(Request."Request No.", 0, "ICR Exception Type"::Currency, 'Missing exchange rate for partner currency handling.');

        RequestLine.SetRange("Request No.", Request."Request No.");
        if RequestLine.FindSet() then
            repeat
                HasLines := true;
                ValidateLine(Request, PartnerSetup, RequestLine);
                TotalAmount += RequestLine."Allocation Amount";
                TotalPercent += RequestLine."Allocation Percent";
            until RequestLine.Next() = 0;

        if not HasLines then
            Error('Recharge request %1 must have at least one allocation line.', Request."Request No.");

        if TotalAmount > Request."Source Amount" then
            RaiseException(Request."Request No.", 0, "ICR Exception Type"::Posting, 'Allocated amount exceeds source amount.');

        if TotalPercent > 100 then
            RaiseException(Request."Request No.", 0, "ICR Exception Type"::Posting, 'Allocated percentage exceeds 100%.');

        Request."Allocated Amount" := TotalAmount;
        Request."Exception Flag" := HasOpenExceptions(Request."Request No.");
        Request.Status := Request.Status::Validated;
        Request."Last Error" := '';
        Request.Modify(true);
        LogAudit(Request, "ICR Audit Action"::Validated, 'Recharge request validated.');
    end;

    procedure GenerateSimulation(var Request: Record "ICR Request Header")
    var
        PartnerSetup: Record "ICR Partner Setup";
        RequestLine: Record "ICR Request Line";
        TargetAmount: Decimal;
    begin
        Request.TestField("Source Amount");
        Request.TestField("Partner Code");
        PartnerSetup.Get(Request."Partner Code");

        RequestLine.SetRange("Request No.", Request."Request No.");
        if RequestLine.FindSet(true) then
            repeat
                if RequestLine."Source G/L Account" = '' then
                    RequestLine."Source G/L Account" := PartnerSetup."Source G/L Account";
                if RequestLine."Target IC G/L Account" = '' then
                    RequestLine."Target IC G/L Account" := PartnerSetup."Target IC G/L Account";
                if RequestLine."Allocation Amount" = 0 then
                    RequestLine."Allocation Amount" := Round(Request."Source Amount" * RequestLine."Allocation Percent" / 100, 0.01);
                TargetAmount := RequestLine."Allocation Amount";
                if Request."Exchange Rate" <> 0 then
                    TargetAmount := Round(RequestLine."Allocation Amount" * Request."Exchange Rate", 0.01);
                RequestLine."Target Amount" := TargetAmount;
                RequestLine."Calculation Trace" := CopyStr(StrSubstNo('%1 allocation from %2 at rate %3.', Format(RequestLine."Allocation Basis"), Format(Request."Source Amount"), Format(Request."Exchange Rate")), 1, MaxStrLen(RequestLine."Calculation Trace"));
                RequestLine.Modify(true);
            until RequestLine.Next() = 0;
    end;

    procedure SubmitForApproval(var Request: Record "ICR Request Header")
    begin
        if Request.Status <> Request.Status::Validated then
            ValidateRequest(Request);

        Request.Status := Request.Status::"Pending Approval";
        Request.Modify(true);
        CreateApprovalEntry(Request, Request.Status, '');
        LogAudit(Request, "ICR Audit Action"::Submitted, 'Recharge request submitted for approval.');
    end;

    procedure Approve(var Request: Record "ICR Request Header")
    begin
        if not (Request.Status in [Request.Status::Validated, Request.Status::"Pending Approval"]) then
            Error('Only validated or pending approval requests can be approved.');

        if (Request."Created By" = CopyStr(UserId(), 1, MaxStrLen(Request."Created By"))) and
           (Request."Source Amount" > Request."Approval Threshold")
        then
            Error('The creator cannot approve this restricted recharge request.');

        Request.Status := Request.Status::Approved;
        Request."Approved By" := CopyStr(UserId(), 1, MaxStrLen(Request."Approved By"));
        Request."Approved DateTime" := CurrentDateTime();
        Request.Modify(true);
        CreateApprovalEntry(Request, Request.Status, 'Approved.');
        LogAudit(Request, "ICR Audit Action"::Approved, 'Recharge request approved.');
    end;

    procedure Reject(var Request: Record "ICR Request Header"; Reason: Text[250])
    begin
        if not (Request.Status in [Request.Status::Validated, Request.Status::"Pending Approval", Request.Status::Approved]) then
            Error('Only validated, pending approval, or approved requests can be rejected.');

        Request.Status := Request.Status::Rejected;
        Request."Rejected By" := CopyStr(UserId(), 1, MaxStrLen(Request."Rejected By"));
        Request."Rejection Reason" := Reason;
        Request.Modify(true);
        CreateApprovalEntry(Request, Request.Status, Reason);
        LogAudit(Request, "ICR Audit Action"::Rejected, Reason);
    end;

    procedure PostApproved(var Request: Record "ICR Request Header")
    var
        ExistingFlow: Record "ICR Flow Entry";
        FlowEntry: Record "ICR Flow Entry";
        RequestLine: Record "ICR Request Line";
        PartnerSetup: Record "ICR Partner Setup";
        ReplayToken: Guid;
    begin
        if Request.Status <> Request.Status::Approved then
            Error('Only approved recharge requests can be posted.');

        if not IsNullGuid(Request."Posting Replay Token") then begin
            ExistingFlow.SetRange("Replay Token", Request."Posting Replay Token");
            if ExistingFlow.FindFirst() then
                Error('Recharge request %1 has already been posted or queued.', Request."Request No.");
        end;

        PartnerSetup.Get(Request."Partner Code");
        ReplayToken := CreateGuid();
        Request."Posting Replay Token" := ReplayToken;

        RequestLine.SetRange("Request No.", Request."Request No.");
        if RequestLine.FindSet(true) then
            repeat
                RequestLine."Posted Document No." := CopyStr(StrSubstNo('ICR-%1-%2', Request."Request No.", RequestLine."Line No."), 1, MaxStrLen(RequestLine."Posted Document No."));
                RequestLine.Modify(true);
            until RequestLine.Next() = 0;

        FlowEntry.Init();
        FlowEntry."Request No." := Request."Request No.";
        FlowEntry.Direction := FlowEntry.Direction::Outbound;
        FlowEntry.Status := FlowEntry.Status::Open;
        FlowEntry."Partner Code" := Request."Partner Code";
        FlowEntry."Source Company" := Request."Source Company";
        FlowEntry."Target Company" := PartnerSetup."Target Company";
        FlowEntry.Amount := Request."Allocated Amount";
        FlowEntry."Currency Code" := Request."Target Currency Code";
        FlowEntry."Exchange Rate" := Request."Exchange Rate";
        FlowEntry."Replay Token" := ReplayToken;
        FlowEntry."External Reference" := CopyStr(StrSubstNo('ICR-%1', Request."Request No."), 1, MaxStrLen(FlowEntry."External Reference"));
        FlowEntry.Insert(true);

        Request.Status := Request.Status::Posted;
        Request."Posted By" := CopyStr(UserId(), 1, MaxStrLen(Request."Posted By"));
        Request."Posted DateTime" := CurrentDateTime();
        Request."Outbox Entry No." := FlowEntry."Entry No.";
        Request.Modify(true);

        CreateReconciliation(Request);
        LogAudit(Request, "ICR Audit Action"::Posted, 'Recharge request posted to intercompany outbox.');
    end;

    procedure SendOutbox(var FlowEntry: Record "ICR Flow Entry")
    var
        Request: Record "ICR Request Header";
    begin
        if FlowEntry.Direction <> FlowEntry.Direction::Outbound then
            Error('Only outbound flow entries can be sent.');
        if FlowEntry.Status <> FlowEntry.Status::Open then
            Error('Only open flow entries can be sent.');

        FlowEntry.Status := FlowEntry.Status::Sent;
        FlowEntry."Processed DateTime" := CurrentDateTime();
        FlowEntry.Modify(true);

        if Request.Get(FlowEntry."Request No.") then
            LogAudit(Request, "ICR Audit Action"::Posted, 'Intercompany outbox entry sent.');
    end;

    procedure AcceptInbound(var FlowEntry: Record "ICR Flow Entry")
    var
        Request: Record "ICR Request Header";
    begin
        if FlowEntry.Status in [FlowEntry.Status::Accepted, FlowEntry.Status::Rejected] then
            Error('This intercompany flow entry is already decided.');

        FlowEntry.Status := FlowEntry.Status::Accepted;
        FlowEntry."Processed DateTime" := CurrentDateTime();
        FlowEntry.Modify(true);

        if Request.Get(FlowEntry."Request No.") then
            LogAudit(Request, "ICR Audit Action"::Accepted, 'Partner accepted the intercompany recharge.');
    end;

    procedure RejectInbound(var FlowEntry: Record "ICR Flow Entry"; Reason: Text[250])
    var
        Request: Record "ICR Request Header";
    begin
        FlowEntry.Status := FlowEntry.Status::Rejected;
        FlowEntry."Last Error" := Reason;
        FlowEntry."Processed DateTime" := CurrentDateTime();
        FlowEntry.Modify(true);

        if Request.Get(FlowEntry."Request No.") then begin
            RaiseException(Request."Request No.", 0, "ICR Exception Type"::Posting, Reason);
            LogAudit(Request, "ICR Audit Action"::Rejected, Reason);
        end;
    end;

    procedure Reverse(var Request: Record "ICR Request Header"; ReasonCode: Code[20])
    var
        RequestLine: Record "ICR Request Line";
    begin
        if Request.Status <> Request.Status::Posted then
            Error('Only posted recharge requests can be reversed.');
        if Request.Reversed then
            Error('Recharge request %1 has already been reversed.', Request."Request No.");

        RequestLine.SetRange("Request No.", Request."Request No.");
        if RequestLine.FindSet(true) then
            repeat
                RequestLine.Reversed := true;
                RequestLine.Modify(true);
            until RequestLine.Next() = 0;

        Request.Reversed := true;
        Request."Reversal Reason Code" := ReasonCode;
        Request.Status := Request.Status::Reversed;
        Request.Modify(true);
        CreateReconciliation(Request);
        LogAudit(Request, "ICR Audit Action"::Reversed, StrSubstNo('Recharge request reversed with reason %1.', ReasonCode));
    end;

    procedure CreateCorrection(SourceRequest: Record "ICR Request Header"; NewRequestNo: Code[20]; Reason: Text[250])
    var
        CorrectionRequest: Record "ICR Request Header";
    begin
        if SourceRequest.Status <> SourceRequest.Status::Posted then
            Error('Only posted requests can be corrected.');

        CorrectionRequest := SourceRequest;
        CorrectionRequest."Request No." := NewRequestNo;
        CorrectionRequest.Status := CorrectionRequest.Status::Draft;
        CorrectionRequest."Original Request No." := SourceRequest."Request No.";
        CorrectionRequest."Correction Reason" := Reason;
        Clear(CorrectionRequest."Posting Replay Token");
        CorrectionRequest."Outbox Entry No." := 0;
        CorrectionRequest.Reversed := false;
        CorrectionRequest."Posted By" := '';
        CorrectionRequest."Posted DateTime" := 0DT;
        CorrectionRequest.Insert(true);

        LogAudit(CorrectionRequest, "ICR Audit Action"::Corrected, Reason);
    end;

    procedure RetryException(var ExceptionEntry: Record "ICR Exception Entry")
    begin
        ExceptionEntry."Retry Count" += 1;
        ExceptionEntry."Last Retry DateTime" := CurrentDateTime();
        ExceptionEntry.Modify(true);
    end;

    procedure MarkExceptionResolved(var ExceptionEntry: Record "ICR Exception Entry")
    begin
        ExceptionEntry.Resolved := true;
        ExceptionEntry.Modify(true);
    end;

    procedure LogAudit(Request: Record "ICR Request Header"; Action: Enum "ICR Audit Action"; Message: Text[250])
    var
        AuditLog: Record "ICR Audit Log";
    begin
        AuditLog.Init();
        AuditLog."Request No." := Request."Request No.";
        AuditLog.Action := Action;
        AuditLog.Status := Request.Status;
        AuditLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(AuditLog."User ID"));
        AuditLog."Logged DateTime" := CurrentDateTime();
        AuditLog.Message := Message;
        AuditLog."Replay Token" := Request."Posting Replay Token";
        AuditLog.Amount := Request."Allocated Amount";
        AuditLog.Insert(true);
    end;

    local procedure ValidateLine(Request: Record "ICR Request Header"; PartnerSetup: Record "ICR Partner Setup"; var RequestLine: Record "ICR Request Line")
    var
        DimensionMapping: Record "ICR Dimension Mapping";
    begin
        if RequestLine."Source G/L Account" = '' then
            RequestLine."Source G/L Account" := PartnerSetup."Source G/L Account";
        if RequestLine."Target IC G/L Account" = '' then
            RequestLine."Target IC G/L Account" := PartnerSetup."Target IC G/L Account";
        if RequestLine."Allocation Basis" = RequestLine."Allocation Basis"::"Fixed Percentage" then
            if RequestLine."Allocation Percent" = 0 then
                Error('Allocation percentage is required on line %1.', RequestLine."Line No.");
        if RequestLine."Allocation Amount" = 0 then
            RequestLine."Allocation Amount" := Round(Request."Source Amount" * RequestLine."Allocation Percent" / 100, 0.01);
        if RequestLine."Manual Override" and (RequestLine."Override Reason" = '') then
            Error('Manual override reason is required on line %1.', RequestLine."Line No.");

        if PartnerSetup."Dimension Mapping Required" and (RequestLine."Source Dimension Code" <> '') then begin
            DimensionMapping.SetRange("Partner Code", Request."Partner Code");
            DimensionMapping.SetRange("Source Dimension Code", RequestLine."Source Dimension Code");
            DimensionMapping.SetRange("Source Dimension Value", RequestLine."Source Dimension Value");
            DimensionMapping.SetRange("Flow Direction", DimensionMapping."Flow Direction"::Outbound);
            DimensionMapping.SetRange(Blocked, false);
            if not DimensionMapping.FindFirst() then
                RaiseException(Request."Request No.", RequestLine."Line No.", "ICR Exception Type"::Mapping, 'Missing dimension translation for outbound recharge line.');
            RequestLine."Target Dimension Code" := DimensionMapping."Target Dimension Code";
            RequestLine."Target Dimension Value" := DimensionMapping."Target Dimension Value";
        end;

        RequestLine."Exception Flag" := HasOpenExceptions(Request."Request No.");
        RequestLine.Modify(true);
    end;

    local procedure CreateApprovalEntry(Request: Record "ICR Request Header"; Status: Enum "ICR Recharge Status"; Reason: Text[250])
    var
        ApprovalEntry: Record "ICR Approval Entry";
    begin
        ApprovalEntry.Init();
        ApprovalEntry."Request No." := Request."Request No.";
        ApprovalEntry."Approver ID" := CopyStr(UserId(), 1, MaxStrLen(ApprovalEntry."Approver ID"));
        ApprovalEntry.Status := Status;
        ApprovalEntry."Threshold Amount" := Request."Approval Threshold";
        ApprovalEntry."Decision DateTime" := CurrentDateTime();
        ApprovalEntry."Decision Reason" := Reason;
        ApprovalEntry.Insert(true);
    end;

    local procedure CreateReconciliation(Request: Record "ICR Request Header")
    var
        ReconciliationEntry: Record "ICR Reconciliation Entry";
    begin
        ReconciliationEntry.Init();
        ReconciliationEntry."Request No." := Request."Request No.";
        ReconciliationEntry."Partner Code" := Request."Partner Code";
        ReconciliationEntry."Posting Date" := Request."Posting Date";
        ReconciliationEntry."Source Amount" := Request."Source Amount";
        ReconciliationEntry."Allocated Amount" := Request."Allocated Amount";
        ReconciliationEntry."Posted Amount" := Request."Allocated Amount";
        ReconciliationEntry.Difference := Request."Source Amount" - Request."Allocated Amount";
        ReconciliationEntry."Currency Code" := Request."Source Currency Code";
        ReconciliationEntry.Status := Request.Status;
        ReconciliationEntry.Reconciled := ReconciliationEntry.Difference = 0;
        ReconciliationEntry.Insert(true);
    end;

    local procedure RaiseException(RequestNo: Code[20]; LineNo: Integer; ExceptionType: Enum "ICR Exception Type"; Message: Text[250])
    var
        ExceptionEntry: Record "ICR Exception Entry";
    begin
        ExceptionEntry.Init();
        ExceptionEntry."Request No." := RequestNo;
        ExceptionEntry."Line No." := LineNo;
        ExceptionEntry."Exception Type" := ExceptionType;
        ExceptionEntry.Message := Message;
        ExceptionEntry.Insert(true);
        Error(Message);
    end;

    local procedure HasOpenExceptions(RequestNo: Code[20]): Boolean
    var
        ExceptionEntry: Record "ICR Exception Entry";
    begin
        ExceptionEntry.SetRange("Request No.", RequestNo);
        ExceptionEntry.SetRange(Resolved, false);
        exit(not ExceptionEntry.IsEmpty());
    end;
}

codeunit 50101 "ICR Job Queue Processor"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessOpenOutbox();
        RetryOpenExceptions();
    end;

    procedure ProcessOpenOutbox()
    var
        FlowEntry: Record "ICR Flow Entry";
        ICRManagement: Codeunit "ICR Management";
    begin
        FlowEntry.SetRange(Direction, FlowEntry.Direction::Outbound);
        FlowEntry.SetRange(Status, FlowEntry.Status::Open);
        if FlowEntry.FindSet(true) then
            repeat
                ICRManagement.SendOutbox(FlowEntry);
            until FlowEntry.Next() = 0;
    end;

    procedure RetryOpenExceptions()
    var
        ExceptionEntry: Record "ICR Exception Entry";
        ICRManagement: Codeunit "ICR Management";
    begin
        ExceptionEntry.SetRange(Resolved, false);
        if ExceptionEntry.FindSet(true) then
            repeat
                ICRManagement.RetryException(ExceptionEntry);
            until ExceptionEntry.Next() = 0;
    end;
}
