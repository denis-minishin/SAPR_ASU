
Dim vsoObject As Object

Sub run(vsoShape As Object)
    Set vsoObject = vsoShape
    frmMenuObjInfo.Height = 100
'    tbCopyRight.Height = 0
    frameCopyRight.Visible = False
    lblName.Caption = vsoShape.name
    lblNameU.Caption = vsoShape.NameU
    lblID.Caption = vsoShape.id
    lblIndex.Caption = vsoShape.Index
    lblGUID.Caption = ""
    If vsoShape.Type <> visTypeForeground Then
        lblGUID.Caption = vsoShape.UniqueID(visGetGUID)
        If vsoShape.Cells("Copyright").FormulaU <> """""" Then
            frameCopyRight.Visible = True
            frmMenuObjInfo.Height = 170
    '        tbCopyRight.Height = 55
            tbCopyRight.Value = vsoShape.Cells("Copyright").ResultStr(0)
        End If
    End If
    On Error Resume Next
    lblNameID.Caption = vsoShape.NameID
    frmMenuObjInfo.Show

End Sub


Private Sub CommandButton1_Click()
    vsoObject.NameU = vsoObject.name
    lblNameU.Caption = vsoObject.NameU
End Sub

Private Sub CommandButton2_Click()
    Application.EventsEnabled = -1
    Application.AlertResponse = 0
    ThisDocument.InitEvent
    Unload Me
End Sub

Private Sub UserForm_Initialize()
    InitCustomCCPMenu Me 'Контекстное меню для TextBox
End Sub

Private Sub UserForm_Terminate()
    DelCustomCCPMenu 'Удаления контекстного меню для TextBox
End Sub