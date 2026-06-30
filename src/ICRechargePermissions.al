permissionset 50100 "ICR Recharge Mgt."
{
    Assignable = true;
    Caption = 'Intercompany Recharge Management';

    Permissions =
        tabledata "ICR Setup" = RIMD,
        tabledata "ICR Partner Setup" = RIMD,
        tabledata "ICR Dimension Mapping" = RIMD,
        tabledata "ICR Request Header" = RIMD,
        tabledata "ICR Request Line" = RIMD,
        tabledata "ICR Audit Log" = RIMD,
        tabledata "ICR Approval Entry" = RIMD,
        tabledata "ICR Exception Entry" = RIMD,
        tabledata "ICR Flow Entry" = RIMD,
        tabledata "ICR Reconciliation Entry" = RIMD,
        table "ICR Setup" = X,
        table "ICR Partner Setup" = X,
        table "ICR Dimension Mapping" = X,
        table "ICR Request Header" = X,
        table "ICR Request Line" = X,
        table "ICR Audit Log" = X,
        table "ICR Approval Entry" = X,
        table "ICR Exception Entry" = X,
        table "ICR Flow Entry" = X,
        table "ICR Reconciliation Entry" = X,
        codeunit "ICR Management" = X,
        codeunit "ICR Job Queue Processor" = X,
        page "ICR Setup" = X,
        page "ICR Partner Setups" = X,
        page "ICR Partner Setup Card" = X,
        page "ICR Dimension Mappings" = X,
        page "ICR Requests" = X,
        page "ICR Request Card" = X,
        page "ICR Request Lines" = X,
        page "ICR Operations Monitor" = X,
        page "ICR Exceptions" = X,
        page "ICR Audit Log" = X,
        page "ICR Reconciliation" = X;
}
