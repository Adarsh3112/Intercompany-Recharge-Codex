table 50100 "ICR Setup"
{
    Caption = 'Intercompany Recharge Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10]) { Caption = 'Primary Key'; }
        field(2; "Source Company"; Text[30]) { Caption = 'Source Company'; }
        field(3; "Default Currency Code"; Code[10]) { Caption = 'Default Currency Code'; TableRelation = Currency.Code; }
        field(4; "Require Approval"; Boolean) { Caption = 'Require Approval'; InitValue = true; }
        field(5; "Approval Threshold"; Decimal) { Caption = 'Approval Threshold'; MinValue = 0; }
        field(6; "Auto Send"; Boolean) { Caption = 'Auto Send'; }
        field(7; "Auto Accept"; Boolean) { Caption = 'Auto Accept'; }
        field(8; "Require Manual Review"; Boolean) { Caption = 'Require Manual Review'; InitValue = true; }
        field(9; "Chunk Size"; Integer) { Caption = 'Chunk Size'; InitValue = 100; MinValue = 1; }
        field(10; "Last Job Queue Run"; DateTime) { Caption = 'Last Job Queue Run'; Editable = false; }
        field(11; "Last Replay Token"; Guid) { Caption = 'Last Replay Token'; Editable = false; }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}

table 50101 "ICR Partner Setup"
{
    Caption = 'Intercompany Recharge Partner Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Partner Code"; Code[20]) { Caption = 'Partner Code'; }
        field(2; "Target Company"; Text[30]) { Caption = 'Target Company'; }
        field(3; "Recharge Type"; Code[20]) { Caption = 'Recharge Type'; }
        field(4; "Allocation Basis"; Enum "ICR Allocation Basis") { Caption = 'Allocation Basis'; }
        field(5; "Source G/L Account"; Code[20]) { Caption = 'Source G/L Account'; TableRelation = "G/L Account"."No."; }
        field(6; "Target IC G/L Account"; Code[20]) { Caption = 'Target IC G/L Account'; TableRelation = "G/L Account"."No."; }
        field(7; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency.Code; }
        field(8; "Currency Rule"; Enum "ICR Currency Rule") { Caption = 'Currency Rule'; }
        field(9; "Approval Threshold"; Decimal) { Caption = 'Approval Threshold'; MinValue = 0; }
        field(10; "Auto Send"; Boolean) { Caption = 'Auto Send'; }
        field(11; "Auto Accept"; Boolean) { Caption = 'Auto Accept'; }
        field(12; "Manual Review Required"; Boolean) { Caption = 'Manual Review Required'; InitValue = true; }
        field(13; Blocked; Boolean) { Caption = 'Blocked'; }
        field(14; "Dimension Mapping Required"; Boolean) { Caption = 'Dimension Mapping Required'; InitValue = true; }
    }

    keys
    {
        key(PK; "Partner Code") { Clustered = true; }
        key(TargetCompany; "Target Company", "Recharge Type") { }
    }
}

table 50102 "ICR Dimension Mapping"
{
    Caption = 'Intercompany Recharge Dimension Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Partner Code"; Code[20]) { Caption = 'Partner Code'; TableRelation = "ICR Partner Setup"."Partner Code"; }
        field(3; "Source Dimension Code"; Code[20]) { Caption = 'Source Dimension Code'; TableRelation = Dimension.Code; }
        field(4; "Source Dimension Value"; Code[20]) { Caption = 'Source Dimension Value'; }
        field(5; "Target Dimension Code"; Code[20]) { Caption = 'Target Dimension Code'; TableRelation = Dimension.Code; }
        field(6; "Target Dimension Value"; Code[20]) { Caption = 'Target Dimension Value'; }
        field(7; "Flow Direction"; Enum "ICR Flow Direction") { Caption = 'Flow Direction'; }
        field(8; Blocked; Boolean) { Caption = 'Blocked'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(PartnerSource; "Partner Code", "Source Dimension Code", "Source Dimension Value", "Flow Direction") { }
    }
}

table 50103 "ICR Request Header"
{
    Caption = 'Intercompany Recharge Request';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request No."; Code[20]) { Caption = 'Request No.'; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
        field(3; Status; Enum "ICR Recharge Status") { Caption = 'Status'; Editable = false; }
        field(4; "Source Company"; Text[30]) { Caption = 'Source Company'; }
        field(5; "Partner Code"; Code[20]) { Caption = 'Partner Code'; TableRelation = "ICR Partner Setup"."Partner Code"; }
        field(6; "Recharge Type"; Code[20]) { Caption = 'Recharge Type'; }
        field(7; "Posting Date"; Date) { Caption = 'Posting Date'; }
        field(8; "Document Date"; Date) { Caption = 'Document Date'; }
        field(9; "Source Amount"; Decimal) { Caption = 'Source Amount'; MinValue = 0; }
        field(10; "Allocated Amount"; Decimal) { Caption = 'Allocated Amount'; Editable = false; }
        field(11; "Source Currency Code"; Code[10]) { Caption = 'Source Currency Code'; TableRelation = Currency.Code; }
        field(12; "Target Currency Code"; Code[10]) { Caption = 'Target Currency Code'; TableRelation = Currency.Code; }
        field(13; "Exchange Rate"; Decimal) { Caption = 'Exchange Rate'; DecimalPlaces = 0 : 9; MinValue = 0; }
        field(14; "Approval Threshold"; Decimal) { Caption = 'Approval Threshold'; Editable = false; }
        field(15; "Exception Flag"; Boolean) { Caption = 'Exception Flag'; Editable = false; }
        field(16; "Approved By"; Code[50]) { Caption = 'Approved By'; Editable = false; }
        field(17; "Approved DateTime"; DateTime) { Caption = 'Approved DateTime'; Editable = false; }
        field(18; "Rejected By"; Code[50]) { Caption = 'Rejected By'; Editable = false; }
        field(19; "Rejection Reason"; Text[250]) { Caption = 'Rejection Reason'; }
        field(20; "Posted By"; Code[50]) { Caption = 'Posted By'; Editable = false; }
        field(21; "Posted DateTime"; DateTime) { Caption = 'Posted DateTime'; Editable = false; }
        field(22; "Posting Replay Token"; Guid) { Caption = 'Posting Replay Token'; Editable = false; }
        field(23; "Outbox Entry No."; Integer) { Caption = 'Outbox Entry No.'; Editable = false; }
        field(24; "Reversed"; Boolean) { Caption = 'Reversed'; Editable = false; }
        field(25; "Reversal Reason Code"; Code[20]) { Caption = 'Reversal Reason Code'; }
        field(26; "Original Request No."; Code[20]) { Caption = 'Original Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(27; "Correction Reason"; Text[250]) { Caption = 'Correction Reason'; }
        field(28; "Last Error"; Text[250]) { Caption = 'Last Error'; Editable = false; }
        field(29; "Created By"; Code[50]) { Caption = 'Created By'; Editable = false; }
        field(30; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Request No.") { Clustered = true; }
        key(StatusPartner; Status, "Partner Code", "Posting Date") { }
    }

    trigger OnInsert()
    begin
        if Status = Status::Draft then;
        "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
        "Created DateTime" := CurrentDateTime();
    end;
}

table 50104 "ICR Request Line"
{
    Caption = 'Intercompany Recharge Request Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Request No."; Code[20]) { Caption = 'Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(3; "Allocation Basis"; Enum "ICR Allocation Basis") { Caption = 'Allocation Basis'; }
        field(4; "Allocation Percent"; Decimal) { Caption = 'Allocation Percent'; DecimalPlaces = 0 : 5; MinValue = 0; MaxValue = 100; }
        field(5; "Allocation Amount"; Decimal) { Caption = 'Allocation Amount'; MinValue = 0; }
        field(6; "Target Amount"; Decimal) { Caption = 'Target Amount'; Editable = false; }
        field(7; "Source G/L Account"; Code[20]) { Caption = 'Source G/L Account'; TableRelation = "G/L Account"."No."; }
        field(8; "Target IC G/L Account"; Code[20]) { Caption = 'Target IC G/L Account'; TableRelation = "G/L Account"."No."; }
        field(9; "Source Dimension Code"; Code[20]) { Caption = 'Source Dimension Code'; TableRelation = Dimension.Code; }
        field(10; "Source Dimension Value"; Code[20]) { Caption = 'Source Dimension Value'; }
        field(11; "Target Dimension Code"; Code[20]) { Caption = 'Target Dimension Code'; TableRelation = Dimension.Code; }
        field(12; "Target Dimension Value"; Code[20]) { Caption = 'Target Dimension Value'; }
        field(13; "Manual Override"; Boolean) { Caption = 'Manual Override'; }
        field(14; "Override Reason"; Text[250]) { Caption = 'Override Reason'; }
        field(15; "Calculation Trace"; Text[250]) { Caption = 'Calculation Trace'; Editable = false; }
        field(16; "Exception Flag"; Boolean) { Caption = 'Exception Flag'; Editable = false; }
        field(17; "Posted Document No."; Code[20]) { Caption = 'Posted Document No.'; Editable = false; }
        field(18; "Reversed"; Boolean) { Caption = 'Reversed'; Editable = false; }
    }

    keys
    {
        key(PK; "Request No.", "Line No.") { Clustered = true; }
    }
}

table 50105 "ICR Audit Log"
{
    Caption = 'Intercompany Recharge Audit Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Request No."; Code[20]) { Caption = 'Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(3; Action; Enum "ICR Audit Action") { Caption = 'Action'; }
        field(4; Status; Enum "ICR Recharge Status") { Caption = 'Status'; }
        field(5; "User ID"; Code[50]) { Caption = 'User ID'; }
        field(6; "Logged DateTime"; DateTime) { Caption = 'Logged DateTime'; }
        field(7; Message; Text[250]) { Caption = 'Message'; }
        field(8; "Replay Token"; Guid) { Caption = 'Replay Token'; }
        field(9; "Amount"; Decimal) { Caption = 'Amount'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(RequestAction; "Request No.", Action, "Logged DateTime") { }
    }
}

table 50106 "ICR Approval Entry"
{
    Caption = 'Intercompany Recharge Approval Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Request No."; Code[20]) { Caption = 'Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(3; "Approver ID"; Code[50]) { Caption = 'Approver ID'; }
        field(4; Status; Enum "ICR Recharge Status") { Caption = 'Status'; }
        field(5; "Threshold Amount"; Decimal) { Caption = 'Threshold Amount'; }
        field(6; "Decision DateTime"; DateTime) { Caption = 'Decision DateTime'; }
        field(7; "Decision Reason"; Text[250]) { Caption = 'Decision Reason'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(RequestStatus; "Request No.", Status) { }
    }
}

table 50107 "ICR Exception Entry"
{
    Caption = 'Intercompany Recharge Exception Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Request No."; Code[20]) { Caption = 'Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(3; "Line No."; Integer) { Caption = 'Line No.'; }
        field(4; "Exception Type"; Enum "ICR Exception Type") { Caption = 'Exception Type'; }
        field(5; Message; Text[250]) { Caption = 'Message'; }
        field(6; Resolved; Boolean) { Caption = 'Resolved'; }
        field(7; "Retry Count"; Integer) { Caption = 'Retry Count'; Editable = false; }
        field(8; "Last Retry DateTime"; DateTime) { Caption = 'Last Retry DateTime'; Editable = false; }
        field(9; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(OpenByRequest; Resolved, "Request No.") { }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime();
    end;
}

table 50108 "ICR Flow Entry"
{
    Caption = 'Intercompany Recharge Flow Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Request No."; Code[20]) { Caption = 'Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(3; Direction; Enum "ICR Flow Direction") { Caption = 'Direction'; }
        field(4; Status; Enum "ICR Flow Status") { Caption = 'Status'; }
        field(5; "Partner Code"; Code[20]) { Caption = 'Partner Code'; TableRelation = "ICR Partner Setup"."Partner Code"; }
        field(6; "Source Company"; Text[30]) { Caption = 'Source Company'; }
        field(7; "Target Company"; Text[30]) { Caption = 'Target Company'; }
        field(8; "Amount"; Decimal) { Caption = 'Amount'; }
        field(9; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency.Code; }
        field(10; "Exchange Rate"; Decimal) { Caption = 'Exchange Rate'; DecimalPlaces = 0 : 9; }
        field(11; "Replay Token"; Guid) { Caption = 'Replay Token'; }
        field(12; "External Reference"; Code[50]) { Caption = 'External Reference'; }
        field(13; "Last Error"; Text[250]) { Caption = 'Last Error'; }
        field(14; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
        field(15; "Processed DateTime"; DateTime) { Caption = 'Processed DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(RequestDirection; "Request No.", Direction, Status) { }
        key(Replay; "Replay Token") { }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime();
    end;
}

table 50109 "ICR Reconciliation Entry"
{
    Caption = 'Intercompany Recharge Reconciliation Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Request No."; Code[20]) { Caption = 'Request No.'; TableRelation = "ICR Request Header"."Request No."; }
        field(3; "Partner Code"; Code[20]) { Caption = 'Partner Code'; TableRelation = "ICR Partner Setup"."Partner Code"; }
        field(4; "Posting Date"; Date) { Caption = 'Posting Date'; }
        field(5; "Source Amount"; Decimal) { Caption = 'Source Amount'; }
        field(6; "Allocated Amount"; Decimal) { Caption = 'Allocated Amount'; }
        field(7; "Posted Amount"; Decimal) { Caption = 'Posted Amount'; }
        field(8; Difference; Decimal) { Caption = 'Difference'; }
        field(9; "Currency Code"; Code[10]) { Caption = 'Currency Code'; TableRelation = Currency.Code; }
        field(10; Status; Enum "ICR Recharge Status") { Caption = 'Status'; }
        field(11; "Reconciled"; Boolean) { Caption = 'Reconciled'; }
        field(12; "Created DateTime"; DateTime) { Caption = 'Created DateTime'; Editable = false; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(RequestPartner; "Request No.", "Partner Code") { }
    }

    trigger OnInsert()
    begin
        "Created DateTime" := CurrentDateTime();
    end;
}
