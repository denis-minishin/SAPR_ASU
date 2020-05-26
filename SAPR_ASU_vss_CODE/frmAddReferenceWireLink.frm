VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} frmAddReferenceWireLink 
   Caption         =   "����� ������� ��������"
   ClientHeight    =   3450
   ClientLeft      =   11445
   ClientTop       =   9390
   ClientWidth     =   6795
   OleObjectBlob   =   "frmAddReferenceWireLink.frx":0000
End
Attribute VB_Name = "frmAddReferenceWireLink"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


'------------------------------------------------------------------------------------------------------------
' Module        : frmAddWireLink - ����� �������� ����� (������������ ������) ��� �������� ��������
' Author        : gtfox �� ������ Shishok::Form_Find
' Date          : 2020.05.24
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
    Fill_lstvParent

    Call lblHeaders_Click

    lblResult.Caption = "������� �����: " & colShapes.Count
    
    ReSize
    
    frmAddReferenceWireLink.Show
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
            Case typeWireLinkR '���� ������ ������������� �������� - ������ ������ ���������
                If vsoShape.Cells("User.Type").Result(0) = typeWireLinkS Then
                    '������� ����� ��� � ���� ��������
                    SelectText vsoShape, vsoPage
                End If
            Case typeWireLinkS '���� ������ ������������� ��������� - ������ ������ ��������
                If vsoShape.Cells("User.Type").Result(0) = typeWireLinkR Then
                    '������ ������� ��������/���������, �.�. � ���������� shpChild ���������� ��������, � � shpParent ��������
                    SelectText vsoShape, vsoPage
                End If
        End Select
    End If
   
End Sub

Sub SelectText(vsoShape As Visio.Shape, vsoPage As Visio.Page) ' ����� - ��������� ��� ��������� + �������
    If optClear Then ' ������ �� ����������� �����
        If vsoShape.CellExistsU("User.LocLink", False) Then ' �������� ������ �����
            If vsoShape.Cells("User.LocLink").ResultStr(0) = "" Then '
                Call AddToCol(vsoShape, vsoPage)
            End If
        End If
    ElseIf optAll Then '��� ������� �������� (����������� � ���)
        Call AddToCol(vsoShape, vsoPage)
    End If
End Sub

Private Sub AddToCol(vsoShape As Visio.Shape, vsoPage As Visio.Page)  ' ���������� ��������� � ���������
    On Error GoTo ExitLine
        colShapes.Add vsoShape.ID ' ��������� ID ������
        colPages.Add vsoPage.ID ' ��������� ID �������
ExitLine:
End Sub

Sub FindShapes() ' ��������� ������
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
    End If

    lblResult.Caption = "������� �����: " & colShapes.Count
    
    ReSize
    
    Call lblHeaders_Click
    
End Sub



Private Sub ReSize() ' ��������� ������ �����. ������� �� ���������� ��������� � listbox
    Dim H As Single
    
    H = lstvPages.ListItems.Count
    If H < lstvParent.ListItems.Count Then H = lstvParent.ListItems.Count

    
    H = H * 12 + 12
    If H < 48 Then H = 48
    If H > 328 Then H = 328
    
    Me.Height = lstvPages.Top + H + 22
    
    lstvPages.Height = H
    lstvParent.Height = H
    
'    H = Me.Height - 35
'
'    Label1.Top = H
'    lblHeaders.Top = H
'    lblContent.Top = H

    
End Sub

Private Sub chkAllPages_Click()

    FindShapes
    
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


Sub Fill_lstvParent() ' ���������� ������ ������������ ��������� �����
    Dim i As Integer
    Dim itmx As ListItem

    lstvParent.ListItems.Clear
    
    For i = 1 To colShapes.Count  ' �������� N ListItem � ��������� ListItems
        With ActiveDocument.Pages.ItemFromID(colPages.Item(i)).Shapes.ItemFromID(colShapes.Item(i))
            Set itmx = lstvParent.ListItems.Add(, colPages.Item(i) & "/" & colShapes.Item(i), IIf(.Cells("Prop.Number").Result(0) = 0, "?", .Cells("Prop.Number").Result(0)) & ":" & .Cells("Prop.Name").ResultStr(0)) 'IIf(.Cells("Prop.Number").Result(0) = 0, "?", .Cells("Prop.Number").Result(0))
                itmx.SubItems(1) = .Cells("User.LocLink").ResultStr(0)
                itmx.SubItems(2) = .Cells("User.Location").ResultStr(0)
                itmx.SubItems(3) = .ContainingPage.Name
        End With
    Next i
    
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
        Case typeWireLinkR '���� ������ ������������� �������� - ������ ������ ���������
            '������� ����� ��� � ���� ��������
            AddReferenceWireLink shpChild, shpParent
        Case typeWireLinkS '���� ������ ������������� ��������� - ������ ������ ��������
            '������ ������� ��������/���������, �.�. � ���������� shpChild ���������� ��������, � � shpParent ��������
            AddReferenceWireLink shpParent, shpChild
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

    lblCurParent.Caption = Item.Text + " " + vsoShape.Cells("User.Location").ResultStr(0)

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

Private Sub optAll_Click()

    FindShapes

End Sub

Private Sub optClear_Click()

    FindShapes
    
End Sub

Private Sub UserForm_Initialize() ' ������������� �����
    Set colShapes = New Collection
    Set colPages = New Collection
    
    Me.Height = 213 ' ������ �����
    
    ActiveWindow.GetViewRect pinLeft, pinTop, pinWidth, pinHeight   '��������� ��� ���� ����� ��������� �����
    
    optClear.Caption = "�� ���������"
    optAll.Caption = "���"
    lblCurParent.Caption = ""
    lblCurPageALL.Caption = "��� ��������"
    lblCurPage.Caption = ActivePage.Name
    chkAllPages.Value = False
    
    lstvPages.ColumnHeaders.Add , , "��������" ' �������� ColumnHeaders
    'Call SendMessage(lstvPages.hWnd, LVM_SETCOLUMNWIDTH, 0, ByVal LVSCW_AUTOSIZE_USEHEADER) ' ��������� ������ �������� �� ����������
    'Call SendMessage(lstvPages.hWnd, LVM_SETCOLUMNWIDTH, 0, ByVal LVSCW_AUTOSIZE) ' ��������� ������ �������� �� �����������
    lstvPages.ColumnHeaders.Item(1).Width = lstvPages.Width - 18
    
    lstvParent.ColumnHeaders.Add , , "������" ' �������� ColumnHeaders
    lstvParent.ColumnHeaders.Add , , "�����" ' �������� ColumnHeaders
    lstvParent.ColumnHeaders.Add , , "�����" ' �������� ColumnHeaders
    lstvParent.ColumnHeaders.Add , , "��������" ' �������� ColumnHeaders
    
    lstvPages.LabelEdit = lvwManual '����� �� ��������������� ������ �������� � ������
    lstvParent.LabelEdit = lvwManual '����� �� ��������������� ������ �������� � ������
    
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
