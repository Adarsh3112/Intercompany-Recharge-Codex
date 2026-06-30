page 50100 "ICR Setup"
{
    Caption = 'Intercompany Recharge Setup';
    PageType = Card;
    SourceTable = "ICR Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Source Company"; Rec."Source Company") { ApplicationArea = All; }
                field("Default Currency Code"; Rec."Default Currency Code") { ApplicationArea = All; }
                field("Require Approval"; Rec."Require Approval") { ApplicationArea = All; }
                field("Approval Threshold"; Rec."Approval Threshold") { ApplicationArea = All; }
                field("Auto Send"; Rec."Auto Send") { ApplicationArea = All; }
                field("Auto Accept"; Rec."Auto Accept") { ApplicationArea = All; }
                field("Require Manual Review"; Rec."Require Manual Review") { ApplicationArea = All; }
                field("Chunk Size"; Rec."Chunk Size") { ApplicationArea = All; }
                field("Last Job Queue Run"; Rec."Last Job Queue Run") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get('SETUP') then begin
            Rec.Init();
            Rec."Primary Key" := 'SETUP';
            Rec."Source Company" := CopyStr(CompanyName(), 1, MaxStrLen(Rec."Source Company"));
            Rec.Insert(true);
        end;
    end;
}

page 50101 "ICR Partner Setups"
{
    Caption = 'Intercompany Recharge Partner Setups';
    PageType = List;
    SourceTable = "ICR Partner Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    CardPageId = "ICR Partner Setup Card";

    layout
    {
        area(Content)
        {
            repeater(Partners)
            {
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Target Company"; Rec."Target Company") { ApplicationArea = All; }
                field("Recharge Type"; Rec."Recharge Type") { ApplicationArea = All; }
                field("Allocation Basis"; Rec."Allocation Basis") { ApplicationArea = All; }
                field("Source G/L Account"; Rec."Source G/L Account") { ApplicationArea = All; }
                field("Target IC G/L Account"; Rec."Target IC G/L Account") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Currency Rule"; Rec."Currency Rule") { ApplicationArea = All; }
                field("Approval Threshold"; Rec."Approval Threshold") { ApplicationArea = All; }
                field("Auto Send"; Rec."Auto Send") { ApplicationArea = All; }
                field("Auto Accept"; Rec."Auto Accept") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}

page 50102 "ICR Partner Setup Card"
{
    Caption = 'Intercompany Recharge Partner Setup';
    PageType = Card;
    SourceTable = "ICR Partner Setup";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Target Company"; Rec."Target Company") { ApplicationArea = All; }
                field("Recharge Type"; Rec."Recharge Type") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
            group(Posting)
            {
                field("Allocation Basis"; Rec."Allocation Basis") { ApplicationArea = All; }
                field("Source G/L Account"; Rec."Source G/L Account") { ApplicationArea = All; }
                field("Target IC G/L Account"; Rec."Target IC G/L Account") { ApplicationArea = All; }
                field("Dimension Mapping Required"; Rec."Dimension Mapping Required") { ApplicationArea = All; }
            }
            group(Currency)
            {
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Currency Rule"; Rec."Currency Rule") { ApplicationArea = All; }
            }
            group(Control)
            {
                field("Approval Threshold"; Rec."Approval Threshold") { ApplicationArea = All; }
                field("Auto Send"; Rec."Auto Send") { ApplicationArea = All; }
                field("Auto Accept"; Rec."Auto Accept") { ApplicationArea = All; }
                field("Manual Review Required"; Rec."Manual Review Required") { ApplicationArea = All; }
            }
            part(Dimensions; "ICR Dimension Mappings")
            {
                ApplicationArea = All;
                SubPageLink = "Partner Code" = field("Partner Code");
            }
        }
    }
}

page 50103 "ICR Dimension Mappings"
{
    Caption = 'Intercompany Recharge Dimension Mappings';
    PageType = ListPart;
    SourceTable = "ICR Dimension Mapping";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Mappings)
            {
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Source Dimension Code"; Rec."Source Dimension Code") { ApplicationArea = All; }
                field("Source Dimension Value"; Rec."Source Dimension Value") { ApplicationArea = All; }
                field("Target Dimension Code"; Rec."Target Dimension Code") { ApplicationArea = All; }
                field("Target Dimension Value"; Rec."Target Dimension Value") { ApplicationArea = All; }
                field("Flow Direction"; Rec."Flow Direction") { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
            }
        }
    }
}

page 50104 "ICR Requests"
{
    Caption = 'Intercompany Recharge Requests';
    PageType = List;
    SourceTable = "ICR Request Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "ICR Request Card";

    layout
    {
        area(Content)
        {
            repeater(Requests)
            {
                field("Request No."; Rec."Request No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Recharge Type"; Rec."Recharge Type") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Source Amount"; Rec."Source Amount") { ApplicationArea = All; }
                field("Allocated Amount"; Rec."Allocated Amount") { ApplicationArea = All; }
                field("Target Currency Code"; Rec."Target Currency Code") { ApplicationArea = All; }
                field("Exception Flag"; Rec."Exception Flag") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ValidateRequest)
            {
                Caption = 'Validate';
                ApplicationArea = All;
                Image = Check;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.ValidateRequest(Rec);
                end;
            }
            action(OpenMonitor)
            {
                Caption = 'Monitor';
                ApplicationArea = All;
                Image = ViewDetails;
                RunObject = page "ICR Operations Monitor";
            }
        }
    }
}

page 50105 "ICR Request Card"
{
    Caption = 'Intercompany Recharge Request';
    PageType = Card;
    SourceTable = "ICR Request Header";
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Request No."; Rec."Request No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Source Company"; Rec."Source Company") { ApplicationArea = All; }
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Recharge Type"; Rec."Recharge Type") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Document Date"; Rec."Document Date") { ApplicationArea = All; }
            }
            group(Amounts)
            {
                field("Source Amount"; Rec."Source Amount") { ApplicationArea = All; }
                field("Allocated Amount"; Rec."Allocated Amount") { ApplicationArea = All; }
                field("Source Currency Code"; Rec."Source Currency Code") { ApplicationArea = All; }
                field("Target Currency Code"; Rec."Target Currency Code") { ApplicationArea = All; }
                field("Exchange Rate"; Rec."Exchange Rate") { ApplicationArea = All; }
                field("Approval Threshold"; Rec."Approval Threshold") { ApplicationArea = All; }
            }
            group(Approval)
            {
                field("Approved By"; Rec."Approved By") { ApplicationArea = All; }
                field("Approved DateTime"; Rec."Approved DateTime") { ApplicationArea = All; }
                field("Rejected By"; Rec."Rejected By") { ApplicationArea = All; }
                field("Rejection Reason"; Rec."Rejection Reason") { ApplicationArea = All; }
            }
            group(Posting)
            {
                field("Posted By"; Rec."Posted By") { ApplicationArea = All; }
                field("Posted DateTime"; Rec."Posted DateTime") { ApplicationArea = All; }
                field("Outbox Entry No."; Rec."Outbox Entry No.") { ApplicationArea = All; }
                field(Reversed; Rec.Reversed) { ApplicationArea = All; }
                field("Reversal Reason Code"; Rec."Reversal Reason Code") { ApplicationArea = All; }
                field("Original Request No."; Rec."Original Request No.") { ApplicationArea = All; }
                field("Correction Reason"; Rec."Correction Reason") { ApplicationArea = All; }
                field("Last Error"; Rec."Last Error") { ApplicationArea = All; }
            }
            part(Lines; "ICR Request Lines")
            {
                ApplicationArea = All;
                SubPageLink = "Request No." = field("Request No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Simulate)
            {
                Caption = 'Simulate';
                ApplicationArea = All;
                Image = Calculate;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.GenerateSimulation(Rec);
                end;
            }
            action(ValidateRequest)
            {
                Caption = 'Validate';
                ApplicationArea = All;
                Image = Check;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.ValidateRequest(Rec);
                end;
            }
            action(Submit)
            {
                Caption = 'Submit';
                ApplicationArea = All;
                Image = SendApprovalRequest;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.SubmitForApproval(Rec);
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.Approve(Rec);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ApplicationArea = All;
                Image = Reject;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.Reject(Rec, Rec."Rejection Reason");
                end;
            }
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = All;
                Image = Post;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.PostApproved(Rec);
                end;
            }
            action(Reverse)
            {
                Caption = 'Reverse';
                ApplicationArea = All;
                Image = ReverseRegister;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.Reverse(Rec, Rec."Reversal Reason Code");
                end;
            }
        }
        area(Navigation)
        {
            action(Audit)
            {
                Caption = 'Audit Log';
                ApplicationArea = All;
                Image = Log;
                RunObject = page "ICR Audit Log";
                RunPageLink = "Request No." = field("Request No.");
            }
            action(Reconciliation)
            {
                Caption = 'Reconciliation';
                ApplicationArea = All;
                Image = Reconcile;
                RunObject = page "ICR Reconciliation";
                RunPageLink = "Request No." = field("Request No.");
            }
            action(Exceptions)
            {
                Caption = 'Exceptions';
                ApplicationArea = All;
                Image = ErrorLog;
                RunObject = page "ICR Exceptions";
                RunPageLink = "Request No." = field("Request No.");
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Source Company" := CopyStr(CompanyName(), 1, MaxStrLen(Rec."Source Company"));
        Rec."Posting Date" := WorkDate();
        Rec."Document Date" := WorkDate();
    end;
}

page 50106 "ICR Request Lines"
{
    Caption = 'Intercompany Recharge Request Lines';
    PageType = ListPart;
    SourceTable = "ICR Request Line";
    ApplicationArea = All;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field("Allocation Basis"; Rec."Allocation Basis") { ApplicationArea = All; }
                field("Allocation Percent"; Rec."Allocation Percent") { ApplicationArea = All; }
                field("Allocation Amount"; Rec."Allocation Amount") { ApplicationArea = All; }
                field("Target Amount"; Rec."Target Amount") { ApplicationArea = All; }
                field("Source G/L Account"; Rec."Source G/L Account") { ApplicationArea = All; }
                field("Target IC G/L Account"; Rec."Target IC G/L Account") { ApplicationArea = All; }
                field("Source Dimension Code"; Rec."Source Dimension Code") { ApplicationArea = All; }
                field("Source Dimension Value"; Rec."Source Dimension Value") { ApplicationArea = All; }
                field("Target Dimension Code"; Rec."Target Dimension Code") { ApplicationArea = All; }
                field("Target Dimension Value"; Rec."Target Dimension Value") { ApplicationArea = All; }
                field("Manual Override"; Rec."Manual Override") { ApplicationArea = All; }
                field("Override Reason"; Rec."Override Reason") { ApplicationArea = All; }
                field("Calculation Trace"; Rec."Calculation Trace") { ApplicationArea = All; }
                field("Posted Document No."; Rec."Posted Document No.") { ApplicationArea = All; }
                field(Reversed; Rec.Reversed) { ApplicationArea = All; }
            }
        }
    }
}

page 50107 "ICR Operations Monitor"
{
    Caption = 'Intercompany Recharge Operations Monitor';
    PageType = List;
    SourceTable = "ICR Flow Entry";
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(Flows)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Request No."; Rec."Request No.") { ApplicationArea = All; }
                field(Direction; Rec.Direction) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Source Company"; Rec."Source Company") { ApplicationArea = All; }
                field("Target Company"; Rec."Target Company") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("External Reference"; Rec."External Reference") { ApplicationArea = All; }
                field("Last Error"; Rec."Last Error") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Send)
            {
                Caption = 'Send';
                ApplicationArea = All;
                Image = SendTo;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.SendOutbox(Rec);
                end;
            }
            action(Accept)
            {
                Caption = 'Accept';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.AcceptInbound(Rec);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ApplicationArea = All;
                Image = Reject;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.RejectInbound(Rec, Rec."Last Error");
                end;
            }
        }
    }
}

page 50108 "ICR Exceptions"
{
    Caption = 'Intercompany Recharge Exceptions';
    PageType = List;
    SourceTable = "ICR Exception Entry";
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(Exceptions)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Request No."; Rec."Request No.") { ApplicationArea = All; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field("Exception Type"; Rec."Exception Type") { ApplicationArea = All; }
                field(Message; Rec.Message) { ApplicationArea = All; }
                field(Resolved; Rec.Resolved) { ApplicationArea = All; }
                field("Retry Count"; Rec."Retry Count") { ApplicationArea = All; }
                field("Last Retry DateTime"; Rec."Last Retry DateTime") { ApplicationArea = All; }
                field("Created DateTime"; Rec."Created DateTime") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Retry)
            {
                Caption = 'Retry';
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.RetryException(Rec);
                end;
            }
            action(Resolve)
            {
                Caption = 'Resolve';
                ApplicationArea = All;
                Image = Completed;

                trigger OnAction()
                var
                    ICRManagement: Codeunit "ICR Management";
                begin
                    ICRManagement.MarkExceptionResolved(Rec);
                end;
            }
        }
    }
}

page 50109 "ICR Audit Log"
{
    Caption = 'Intercompany Recharge Audit Log';
    PageType = List;
    SourceTable = "ICR Audit Log";
    ApplicationArea = All;
    UsageCategory = History;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Audit)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Request No."; Rec."Request No.") { ApplicationArea = All; }
                field(Action; Rec.Action) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("User ID"; Rec."User ID") { ApplicationArea = All; }
                field("Logged DateTime"; Rec."Logged DateTime") { ApplicationArea = All; }
                field(Message; Rec.Message) { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
            }
        }
    }
}

page 50110 "ICR Reconciliation"
{
    Caption = 'Intercompany Recharge Reconciliation';
    PageType = List;
    SourceTable = "ICR Reconciliation Entry";
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Reconciliation)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Request No."; Rec."Request No.") { ApplicationArea = All; }
                field("Partner Code"; Rec."Partner Code") { ApplicationArea = All; }
                field("Posting Date"; Rec."Posting Date") { ApplicationArea = All; }
                field("Source Amount"; Rec."Source Amount") { ApplicationArea = All; }
                field("Allocated Amount"; Rec."Allocated Amount") { ApplicationArea = All; }
                field("Posted Amount"; Rec."Posted Amount") { ApplicationArea = All; }
                field(Difference; Rec.Difference) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Reconciled; Rec.Reconciled) { ApplicationArea = All; }
            }
        }
    }
}
