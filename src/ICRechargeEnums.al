enum 50100 "ICR Recharge Status"
{
    Extensible = true;

    value(0; Draft) { Caption = 'Draft'; }
    value(1; Validated) { Caption = 'Validated'; }
    value(2; "Pending Approval") { Caption = 'Pending Approval'; }
    value(3; Approved) { Caption = 'Approved'; }
    value(4; Rejected) { Caption = 'Rejected'; }
    value(5; Posted) { Caption = 'Posted'; }
    value(6; Reversed) { Caption = 'Reversed'; }
    value(7; Closed) { Caption = 'Closed'; }
}

enum 50101 "ICR Allocation Basis"
{
    Extensible = true;

    value(0; "Fixed Percentage") { Caption = 'Fixed Percentage'; }
    value(1; "Amount Based") { Caption = 'Amount Based'; }
    value(2; "Dimension Driven") { Caption = 'Dimension Driven'; }
    value(3; Headcount) { Caption = 'Headcount'; }
    value(4; Manual) { Caption = 'Manual'; }
}

enum 50102 "ICR Currency Rule"
{
    Extensible = true;

    value(0; "Source Currency") { Caption = 'Source Currency'; }
    value(1; "Partner Currency") { Caption = 'Partner Currency'; }
    value(2; "Exchange Rate Required") { Caption = 'Exchange Rate Required'; }
    value(3; "Manual Rate") { Caption = 'Manual Rate'; }
}

enum 50103 "ICR Flow Direction"
{
    Extensible = true;

    value(0; Outbound) { Caption = 'Outbound'; }
    value(1; Inbound) { Caption = 'Inbound'; }
}

enum 50104 "ICR Flow Status"
{
    Extensible = true;

    value(0; Open) { Caption = 'Open'; }
    value(1; Sent) { Caption = 'Sent'; }
    value(2; Accepted) { Caption = 'Accepted'; }
    value(3; Rejected) { Caption = 'Rejected'; }
    value(4; Failed) { Caption = 'Failed'; }
    value(5; Replayed) { Caption = 'Replayed'; }
}

enum 50105 "ICR Audit Action"
{
    Extensible = true;

    value(0; Created) { Caption = 'Created'; }
    value(1; Validated) { Caption = 'Validated'; }
    value(2; Submitted) { Caption = 'Submitted'; }
    value(3; Approved) { Caption = 'Approved'; }
    value(4; Rejected) { Caption = 'Rejected'; }
    value(5; Posted) { Caption = 'Posted'; }
    value(6; Reversed) { Caption = 'Reversed'; }
    value(7; Corrected) { Caption = 'Corrected'; }
    value(8; Failed) { Caption = 'Failed'; }
    value(9; Accepted) { Caption = 'Accepted'; }
    value(10; Replayed) { Caption = 'Replayed'; }
}

enum 50106 "ICR Exception Type"
{
    Extensible = true;

    value(0; Mapping) { Caption = 'Mapping'; }
    value(1; Currency) { Caption = 'Currency'; }
    value(2; Approval) { Caption = 'Approval'; }
    value(3; Posting) { Caption = 'Posting'; }
    value(4; Duplicate) { Caption = 'Duplicate'; }
    value(5; Reversal) { Caption = 'Reversal'; }
}
