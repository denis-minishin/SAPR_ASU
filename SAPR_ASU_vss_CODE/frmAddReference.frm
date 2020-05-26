VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmAddReference 
   Caption         =   "����� �������� �����"
   ClientHeight    =   3465
   ClientLeft      =   11445
   ClientTop       =   9390
   ClientWidth     =   5535
   OleObjectBlob   =   "frmAddReference.frx":0000
End
Attribute VB_Name = "frmAddReference"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------------------------------------
' Module        : frmAddReference - ����� �������� ������ (������������ ������) ��������� �����
' Author        : gtfox �� ������ Shishok::Form_Find
' Date          : 2020.05.19
' Description   : �������� ������� �������� ���� �������� ����� �����
' Link          : https://visio.getbb.ru/viewtopic.php?f=44&t=1491, https://yadi.sk/d/24V8ngEM_8KXyg
'------------------------------------------------------------------------------------------------------------
                '�� ������ �����:
                '------------------------------------------------------------------------------------------------------------
                ' Module    : Form_Find ����� � ���������
                ' Author    : Shishok
                ' Date      : 11.06.2018
                ' Purpose   : ����� � ��������� ������ �� ��������(�����). ��� Windows 7 x 32 ��� ���� ����
                ' Links     : https://github.com/Shishok/, https://yadi.sk/d/qbpj9WI9d2eqF
                '------------------------------------------------------------------------------------------------------------

'Option Explicit
'Option Base 1

Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd&, ByVal wMsg&, ByVal wParam&, lParam As Any) As Long
Private Const LVM_FIRST As Long = &H1000   ' 4096
Private Const LVM_SETCOLUMNWIDTH As Long = (LVM_FIRST + 30)   ' 4126
Private Const LVSCW_AUTOSIZE As Long = -1
Private Const LVSCW_AUTOSIZE_USEHEADER As Long = -2

Dim shpChild As Visio.Shape '���� �� ������ CrossReference
Dim shpParent As Visio.Shape '���� �������� � ����� lstvParent. ����� ��� �������� �����
Dim colShapes As Collection
Dim colPages As Collection
Dim FindeType As Integer '��� �������� �������� ����� (�������/��������)
Public pinLeft As Double, pinTop As Double, pinWidth As Double, pinHeight As Double '��� ���������� ���� ���� ����� ��������� �����

Sub Run(vsoShape As Visio.Shape) '������� ���� �� ������ CrossReference
    Set shpChild = vsoShape '� ���������� ��� � ����� frmAddReference
    
    FindeType = shpChild.Cells("User.Type").Result(0)
    
    Fill_lstvPages
    
    Fill_ShapeCollection ActivePage
    
    Select Case FindeType
        Case typeNO, typeNC '���� ������ ������������� �������� - ������ ������ ���������
            lstvParent.ColumnHeaders.Add , , "��������" ' �������� ColumnHeaders
            lstvParent.ColumnHeaders.Item(1).Width = lstvParent.Width - 18
        Case typeCoil, typeParent '���� ������ ������������� ��������� - ������ ������ ��������
            lstvParent.ColumnHeaders.Add , , "�������" ' �������� ColumnHeaders
            lstvParent.ColumnHeaders.Add , , "�����" ' �������� ColumnHeaders
            lstvParent.ColumnHeaders.Add , , "�����" ' �������� ColumnHeaders
            lstvParent.ColumnHeaders.Add , , "��������" ' �������� ColumnHeaders
            lstvChild.Visible = False
            lstvParent.Width = 170
            lblResult.Left = 200
            btnClose.Left = 200
            Me.Width = 286
    End Select
    
    Fill_lstvParent

    Call lblHeaders_Click

    lblResult.Caption = "������� �����: " & colShapes.Count
    
    ReSize

    frmAddReference.Show
End Sub

Sub Fill_ShapeCollection(vsoPage As Visio.Page) '��������� ������ � ������������� ����������
    'Dim vsoPage As Visio.Page
    Dim vsoShape As Visio.Shape
    
    If chkAllPages Then
        For Each vsoPage In ActiveDocument.Pages ' ������� ������� ��������� � ������
            For Each vsoShape In vsoPage.Shapes
                SelectType vsoShape, vsoPage
            Next
        Next
    Else
        For Each vsoShape In vsoPage.Shapes ' ������� ������ �� ��������� ��������
            SelectType vsoShape, vsoPage
        Next
    End If
    
End Sub

Private Sub SelectType(vsoShape As Visio.Shape, vsoPage As Visio.Page) ' ����� �� ����

    If vsoShape.CellExistsU("User.Type", 0) Then '��������� ����������� ����� �� ������� ���� ���
        Select Case FindeType '������������ � ������������ � ����� ���������� ������ �����
            Case typeNO, typeNC '���� ������ ������������� �������� - ������ ������ ���������
                Select Case vsoShape.Cells("User.Type").Result(0)
                    Case typeCoil, typeParent
                        '������� ����� ��� � ���� ��������
                        SelectText vsoShape, vsoPage
                End Select
            Case typeCoil, typeParent '���� ������ ������������� ��������� - ������ ������ ��������
                Select Case vsoShape.Cells("User.Type").Result(0)
                    Case typeNO, typeNC
                        '������ ������� ��������/���������, �.�. � ���������� shpChild ���������� ��������, � � shpParent ��������
                        SelectText vsoShape, vsoPage
                End Select
        End Select
    End If
   
End Sub

Sub SelectText(vsoShape As Visio.Shape, vsoPage As Visio.Page) ' ����� - �� ������
    Dim shtxt As String, txt As String
    
    shtxt = Switch(chkCase = True, vsoShape.Characters.Text, chkCase = False, LCase(vsoShape.Characters.Text))
    txt = Switch(chkCase = True, txtShapeText.Text, chkCase = False, LCase(txtShapeText.Text))
    
    If shtxt Like txt Then ' �������� ������ �����
        Call AddToCol(vsoShape, vsoPage)
    End If
    
End Sub

Private Sub AddToCol(vsoShape As Visio.Shape, vsoPage As Visio.Page)  ' ���������� ��������� � ���������
    On Error GoTo ExitLine
        colShapes.Add vsoShape.ID ' ��������� ID ������
        colPages.Add vsoPage.ID ' ��������� ID �������
ExitLine:
End Sub


Private Sub btnFindAll_Click() ' ��������� ������ �� ������

    FindShapes
    
End Sub

Private Sub FindShapes() ' ��������� ������
    Set colShapes = New Collection
    Set colPages = New Collection

    Fill_ShapeCollection ActiveDocument.Pages(lblCurPage.Caption)
    
    If chkAllPages.Value Then
        lblCurPageALL.Visible = True
        lblCurPage.Visible = False
    Else
        lblCurPageALL.Visible = False
        lblCurPage.Visible = True
    End If
    
    If colShapes.Count > 0 Then
        Fill_lstvParent
    Else
        lstvParent.ListItems.Clear
        lstvChild.ListItems.Clear
    End If

    lblResult.Caption = "������� �����: " & colShapes.Count
    
    ReSize
    
    Call lblHeaders_Click
    
End Sub



Private Sub ReSize() ' ��������� ������ �����. ������� �� ���������� ��������� � listbox
    Dim H As Single
    
    H = lstvPages.ListItems.Count
    If H < lstvParent.ListItems.Count Then H = lstvParent.ListItems.Count
    If H < lstvChild.ListItems.Count Then H = lstvChild.ListItems.Count
    
    H = H * 12 + 12
    If H < 48 Then H = 48
    If H > 328 Then H = 328
    
    Me.Height = lstvPages.Top + H + 22
    
    lstvPages.Height = H
    lstvParent.Height = H
    lstvChild.Height = H


    
End Sub

Private Sub chkAllPages_Click()

    FindShapes
    
End Sub

Private Sub lstvChild_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Dim vsoShape As Visio.Shape
    Dim ShapeID As String
    Dim PageID As String
    Dim mstrShPgID() As String

    mstrShPgID = Split(Item.Key, "/")
    PageID = mstrShPgID(0)   ' ID ��������
    ShapeID = mstrShPgID(1)   ' ID �����

    With ActiveWindow
        .Page = ActiveDocument.Pages.ItemFromID(PageID) ' ��������� ������ ��������
        Set vsoShape = ActivePage.Shapes.ItemFromID(ShapeID)
        .Select vsoShape, visDeselectAll + visSelect     ' ��������� �����
        '.CenterViewOnShape ActivePage.Shapes(shName) , visCenterViewSelectShape '2010+
        .SetViewRect vsoShape.Cells("PinX") - pinWidth / 2, vsoShape.Cells("PinY") + pinHeight / 2, pinWidth, pinHeight
        '[�����] , [�������] ���� , [������] , [������](����) �������� ����
    End With
    
End Sub

Private Sub lstvChild_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader) ' ���������� ��� ����� �� ���������

    With lstvChild
        .Sorted = False
        .SortKey = ColumnHeader.SubItemIndex
        '�������� ������� ���������� �� �������� ����������
        .SortOrder = Abs(.SortOrder Xor 1)
        .Sorted = True
    End With
    
End Sub

Private Sub lstvPages_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader) ' ���������� ��� ����� �� ���������

    With lstvPages
        .Sorted = False
        .SortKey = ColumnHeader.SubItemIndex
        '�������� ������� ���������� �� �������� ����������
        .SortOrder = Abs(.SortOrder Xor 1)
        .Sorted = True
    End With
    
End Sub

Private Sub lstvParent_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader) ' ���������� ��� ����� �� ���������

    With lstvParent
        .Sorted = False
        .SortKey = ColumnHeader.SubItemIndex
        '�������� ������� ���������� �� �������� ����������
        .SortOrder = Abs(.SortOrder Xor 1)
        .Sorted = True
    End With
    
End Sub

Sub Fill_lstvChild(vsoShape As Visio.Shape) ' ���������� ������ �������� ��������� ����� (���������)
    Dim i As Integer
    Dim itmx As ListItem
    Dim mstrAdrChild() As String
    Dim shpInfoChild As Visio.Shape
    
    lstvChild.ListItems.Clear
    
    If vsoShape.CellExistsU("Scratch.A1", 0) Then
        For i = 1 To vsoShape.Section(visSectionScratch).Count
            If vsoShape.CellsU("Scratch.A" & i).ResultStr(0) <> "" Then
                '��������� HyperLink �� ��� �������� � ��� �����
                mstrAdrChild = Split(vsoShape.CellsU("Scratch.A" & i).ResultStr(0), "/")
                Set shpInfoChild = ActiveDocument.Pages(mstrAdrChild(0)).Shapes(mstrAdrChild(1))
                Set itmx = lstvChild.ListItems.Add(, shpInfoChild.ContainingPage.ID & "/" & shpInfoChild.ID, _
                shpInfoChild.Characters.Text + " " + IIf(shpInfoChild.CellsU("User.Type").Result(0) = typeNO, "NO", "NC") _
                + " " + shpInfoChild.CellsU("User.Location").ResultStr(0)) '
            End If
        Next
    End If
    
End Sub

Sub Fill_lstvParent() ' ���������� ������ ������������ ��������� �����
    Dim i As Integer
    Dim itmx As ListItem
    
    lstvParent.ListItems.Clear
    
    Select Case FindeType
        Case typeNO, typeNC '���� ������ ������������� �������� - ������ ������ ���������
            For i = 1 To colShapes.Count  ' �������� N ListItem � ��������� ListItems
                With ActiveDocument.Pages.ItemFromID(colPages.Item(i)).Shapes.ItemFromID(colShapes.Item(i))
                Set itmx = lstvParent.ListItems.Add(, colPages.Item(i) & "/" & colShapes.Item(i), .Characters.Text) '.Cells("TheText").ResultStr("")
              End With
            Next i
        Case typeCoil, typeParent '���� ������ ������������� ��������� - ������ ������ ��������
            For i = 1 To colShapes.Count  ' �������� N ListItem � ��������� ListItems
                With ActiveDocument.Pages.ItemFromID(colPages.Item(i)).Shapes.ItemFromID(colShapes.Item(i))
                    Set itmx = lstvParent.ListItems.Add(, colPages.Item(i) & "/" & colShapes.Item(i), .Characters.Text) '.Cells("TheText").ResultStr("")
                    itmx.SubItems(1) = IIf(.Cells("User.LocationParent").ResultStr(0) = "0,0000", "", .Cells("User.LocationParent").ResultStr(0))
                    itmx.SubItems(2) = .Cells("User.Location").ResultStr(0)
                    itmx.SubItems(3) = .ContainingPage.Name
                End With
            Next i
    End Select

End Sub

Private Sub Fill_lstvPages()   ' ���������� ������ �������
    Dim i As Integer
    Dim itmx As ListItem
    Dim vsoPage As Visio.Page
    
    lstvPages.ListItems.Clear
    
    For Each vsoPage In ActiveDocument.Pages
        If vsoPage.PageSheet.CellExistsU("Prop.NomerShemy", 0) Then
            Set itmx = lstvPages.ListItems.Add(, vsoPage.ID & "/", vsoPage.Name)
        End If
    Next
    
End Sub

Private Sub lstvPages_ItemClick(ByVal Item As MSComctlLib.ListItem)
    
    chkAllPages.Value = False
    lblCurPage.Caption = Item.Text
    lblCurPage.Visible = True
    lblCurPageALL.Visible = False
    
    FindShapes
    
End Sub

Private Sub lstvParent_DblClick()

    Select Case FindeType
        Case typeNO, typeNC '���� ������ ������������� �������� - ������ ������ ���������
            '������� ����� ��� � ���� ��������
            AddReference shpChild, shpParent
        Case typeCoil, typeParent '���� ������ ������������� ��������� - ������ ������ ��������
            '������ ������� ��������/���������, �.�. � ���������� shpChild ���������� ��������, � � shpParent ��������
            AddReference shpParent, shpChild
    End Select

    '��������� �������. ��� ���� ������������������� xD
    Set ActivePages = ActiveDocument.Pages
    
    btnClose_Click
    
End Sub

Private Sub lstvParent_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Dim vsoShape As Visio.Shape
    Dim ShapeID As String
    Dim PageID As String
    Dim mstrShPgID() As String
    
    lblCurParent.Caption = Item.Text
    
    mstrShPgID = Split(Item.Key, "/")
    PageID = mstrShPgID(0)   ' ID ��������
    ShapeID = mstrShPgID(1)   ' ID �����

    With ActiveWindow
        .Page = ActiveDocument.Pages.ItemFromID(PageID) ' ��������� ������ ��������
        Set vsoShape = ActivePage.Shapes.ItemFromID(ShapeID)
        If vsoShape.Parent.Type = 2 Then
            .Select vsoShape, visDeselectAll + visSubSelect  ' ��������� ��������
            '.CenterViewOnShape ActivePage.Shapes(shName), visCenterViewSelectShape '2010+
        Else
            .Select vsoShape, visDeselectAll + visSelect     ' ��������� �����
            '.CenterViewOnShape ActivePage.Shapes(shName) , visCenterViewSelectShape '2010+
            .SetViewRect vsoShape.Cells("PinX") - pinWidth / 2, vsoShape.Cells("PinY") + pinHeight / 2, pinWidth, pinHeight
            '[�����] , [�������] ���� , [������] , [������](����) �������� ����
        End If
    End With

    If vsoShape.CellExistsU("User.Location", 0) Then
        lblCurParent.Caption = Item.Text + "  " + vsoShape.Cells("User.Location").ResultStr(0)
    End If
    
    Select Case FindeType
        Case typeNO, typeNC '���� ������ ������������� �������� - ������ ������ ���������
            Fill_lstvChild vsoShape '��������� ���� ���������
        Case typeCoil, typeParent '���� ������ ������������� ��������� - ������ ������ ��������
            '���� �� ������
    End Select
    
    
    
    Set shpParent = vsoShape '�������� �������� ��� �������� �����
    
End Sub

Private Sub lblContent_Click() ' ��������� ������ �������� �� �����������
   Dim colNum As Long
   For colNum = 0 To lstvParent.ColumnHeaders.Count - 1
      Call SendMessage(lstvParent.hWnd, LVM_SETCOLUMNWIDTH, colNum, ByVal LVSCW_AUTOSIZE)
   Next
End Sub

Private Sub lblHeaders_Click() ' ��������� ������ �������� �� ����������
   Dim colNum As Long
   For colNum = 0 To lstvParent.ColumnHeaders.Count - 1
      Call SendMessage(lstvParent.hWnd, LVM_SETCOLUMNWIDTH, colNum, ByVal LVSCW_AUTOSIZE_USEHEADER)
   Next
End Sub

Private Sub UserForm_Initialize() ' ������������� �����
    Set colShapes = New Collection
    Set colPages = New Collection
    
    Me.Height = 213 ' ������ �����
    
    ActiveWindow.GetViewRect pinLeft, pinTop, pinWidth, pinHeight   '��������� ��� ���� ����� ��������� �����
    
    txtShapeText.Text = "*" ' ������� ������ � ���� ������
    lblCurParent.Caption = ""
    lblCurPageALL.Caption = "��� ��������"
    lblCurPage.Caption = ActivePage.Name
    chkAllPages.Value = False
    
    lstvPages.ColumnHeaders.Add , , "��������" ' �������� ColumnHeaders
    'Call SendMessage(lstvPages.hWnd, LVM_SETCOLUMNWIDTH, 0, ByVal LVSCW_AUTOSIZE_USEHEADER) ' ��������� ������ �������� �� ����������
    'Call SendMessage(lstvPages.hWnd, LVM_SETCOLUMNWIDTH, 0, ByVal LVSCW_AUTOSIZE) ' ��������� ������ �������� �� �����������
    lstvPages.ColumnHeaders.Item(1).Width = lstvPages.Width - 18
 
    lstvChild.ColumnHeaders.Add , , "��������" ' �������� ColumnHeaders
    'Call SendMessage(lstvChild.hWnd, LVM_SETCOLUMNWIDTH, 0, ByVal LVSCW_AUTOSIZE_USEHEADER)  ' ��������� ������ �������� �� ����������
    'Call SendMessage(lstvChild.hWnd, LVM_SETCOLUMNWIDTH, 0, ByVal LVSCW_AUTOSIZE) ' ��������� ������ �������� �� �����������
    lstvChild.ColumnHeaders.Item(1).Width = lstvParent.Width - 4
    
    lstvPages.LabelEdit = lvwManual '����� �� ��������������� ������ �������� � ������
    lstvParent.LabelEdit = lvwManual '����� �� ��������������� ������ �������� � ������
    lstvChild.LabelEdit = lvwManual '����� �� ��������������� ������ �������� � ������


End Sub

Private Sub btnClose_Click() ' �������� �����

    With ActiveWindow
        .Page = shpChild.ContainingPage
        .Select shpChild, visDeselectAll + visSelect     ' ��������� �����
        .SetViewRect pinLeft, pinTop, pinWidth, pinHeight  '�������������� ���� ���� ����� �������� �����
                    '[�����] , [�������] ���� , [������] , [������](����) �������� ����
    End With
    Unload Me
    
End Sub
