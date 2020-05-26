Attribute VB_Name = "CrossReference"
'------------------------------------------------------------------------------------------------------------
' Module        : CrossReference - ������������ ������ ��������� �����
' Author        : gtfox
' Date          : 2020.05.17
' Description   : ������������ ������ ��������� ����� � �� �����������
' Link          : https://visio.getbb.ru/viewtopic.php?f=44&t=1491, https://yadi.sk/d/24V8ngEM_8KXyg
'------------------------------------------------------------------------------------------------------------

Option Explicit


'��������� ����� �������� ����� ��������� �����
Public Sub AddReferenceFrm(shpChild As Visio.Shape) '�������� ���� � �����
    Load frmAddReference
    frmAddReference.Run shpChild '�������� ��� � �����
End Sub

'��������� ����� �������� ����� �������� ��������
Public Sub AddReferenceWireLinkFrm(shpChild As Visio.Shape) '�������� ���� � �����
    Load frmAddReferenceWireLink
    frmAddReferenceWireLink.Run shpChild '�������� ��� � �����
End Sub


Sub AddLocThumb(vsoShape As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : AddLocThumb - ��������� ��������� ��������� ��� ����
                '��������� ��� ������� ���� ��������� ���� �������� ���������
                '��������� ��� ������� ���� ��������� ������� ����
                
                '����� ������� �� ���� = CALLTHIS("CrossReference.AddLocThumb","SAPR_ASU")
'------------------------------------------------------------------------------------------------------------
    Dim shpThumb As Visio.Shape
    Dim vsoPage As Visio.Page
    Dim vsoMaster As Visio.Master
    Dim DeltaX As Single
    Dim DeltaY As Single
    Dim dN As Single '�������� �������� �� ���������
    Dim i As Integer
    Dim n As Integer '����� ��������� � �������
    
    DeltaX = 0.295275590551181
    DeltaY = -0.246062992125984
    dN = -9.84251968503937E-02
    
    Set vsoPage = ActivePage
    Set vsoMaster = Application.Documents.Item("SAPR_ASU_SHAPE.vss").Masters.Item("Thumb")
    
    
    If vsoShape.CellExistsU("User.Type", 0) Then
        '�������� ���� ���� �������� ���������
        Select Case vsoShape.Cells("User.Type").Result(0)
        
            Case typeNO, typeNC '��������
            
                If vsoShape.Cells("Hyperlink.Coil.SubAddress").ResultStr(0) <> "" Then
                    '��������� ��������� �������� Thumbnail
                    Set shpThumb = vsoPage.Drop(vsoMaster, vsoShape.Cells("PinX").Result(0), vsoShape.Cells("PinY").Result(0))
                    '��������� ����
                    shpThumb.Cells("User.LocType").FormulaU = typeCoil
                    shpThumb.Cells("User.Location").FormulaU = vsoShape.NameU & "!User.LocationParent"
                    shpThumb.Cells("User.AdrSource").FormulaU = Chr(34) & vsoShape.ContainingPageID & "/" & vsoShape.ID & Chr(34)
                    shpThumb.Cells("User.DeltaX").FormulaU = Chr(34) & DeltaX & Chr(34) 'shpThumb.Cells("PinX").ResultStrU("in")
                    shpThumb.Cells("User.DeltaY").FormulaU = Chr(34) & DeltaY & Chr(34) 'shpThumb.Cells("PinY").ResultStrU("in")
                    shpThumb.Cells("PinX").FormulaU = "=SETATREF(User.DeltaX,SETATREFEVAL(SETATREFEXPR(0)-Sheet." & vsoShape.ID & "!PinX))+Sheet." & vsoShape.ID & "!PinX"
                    shpThumb.Cells("PinY").FormulaU = "=SETATREF(User.DeltaY,SETATREFEVAL(SETATREFEXPR(0)-Sheet." & vsoShape.ID & "!PinY))+Sheet." & vsoShape.ID & "!PinY"
                End If
                
            Case typeCoil '������� ����
            
                n = 0
                '���������� �������� ������ �� ��������
                For i = 1 To vsoShape.Section(visSectionScratch).Count '���� ������ � Scratch
                    If vsoShape.CellsU("Scratch.A" & i).ResultStr(0) <> "" Then '�� ������ ������
                        '��������� ��������� �������� Thumbnail
                        Set shpThumb = vsoPage.Drop(vsoMaster, vsoShape.Cells("PinX").Result(0), vsoShape.Cells("PinY").Result(0))
                        '��������� ����
                        shpThumb.Cells("User.LocType").FormulaU = vsoShape.NameU & "!Scratch.D" & i
                        shpThumb.Cells("User.Location").FormulaU = vsoShape.NameU & "!Scratch.C" & i
                        shpThumb.Cells("User.AdrSource").FormulaU = Chr(34) & vsoShape.ContainingPageID & "/" & vsoShape.ID & Chr(34)
                        shpThumb.Cells("User.DeltaX").FormulaU = Chr(34) & DeltaX & Chr(34) 'shpThumb.Cells("PinX").ResultStrU("in")
                        shpThumb.Cells("User.DeltaY").FormulaU = Chr(34) & (DeltaY + n * dN) & Chr(34) 'shpThumb.Cells("PinY").ResultStrU("in")
                        shpThumb.Cells("PinX").FormulaU = "=SETATREF(User.DeltaX,SETATREFEVAL(SETATREFEXPR(0)-Sheet." & vsoShape.ID & "!PinX))+Sheet." & vsoShape.ID & "!PinX"
                        shpThumb.Cells("PinY").FormulaU = "=SETATREF(User.DeltaY,SETATREFEVAL(SETATREFEXPR(0)-Sheet." & vsoShape.ID & "!PinY))+Sheet." & vsoShape.ID & "!PinY"
                        n = n + 1
                    End If
                Next
        End Select
    End If
    ActiveWindow.DeselectAll
End Sub





Sub AddReference(shpChild As Visio.Shape, shpParent As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : AddReference - ������� ����� ����� �������� � ������������ ���������

                '����� ������ ���������(�������)/�������������(�������) �������� ��������� ���������� ���� ��� ������� �� ���
                '���(Sheet.4), ��������(�����.3), ����(Pages[�����.3]!Sheet.4), ������(HyperLink="�����.3/Sheet.4"),
                '��� ��������(NO/NC), ��������������(/14.E7), ����� ��������(KL1.3)
                '������ �� �������� � ������� ����������� ��������� � ShapeSheet
                '��������� ��������� ��������������, ��������� � Scratch.B1-B4 �������
                '��������� � ������� ����� ���� 4
'------------------------------------------------------------------------------------------------------------
    'Dim shpParent As Visio.Shape
    Dim shpParentOld As Visio.Shape
    'Dim shpChild As Visio.Shape
    Dim PageParent, NameIdParent, AdrParent As String
    Dim PageChild, NameIdChild, AdrChild As String
    Dim i As Integer
    Dim HyperLinkToChild As String
    Dim HyperLinkToParentOld As String
    Dim mstrAdrParentOld() As String
    
    'Set shpChild = ActivePage.Shapes("Sheet.72") '��� �������
    'Set shpParent = ActivePage.Shapes("Sheet.7") '��� �������

    PageParent = shpParent.ContainingPage.NameU
    NameIdParent = shpParent.NameID
    AdrParent = "Pages[" + PageParent + "]!" + NameIdParent
    
    PageChild = shpChild.ContainingPage.NameU
    NameIdChild = shpChild.NameID
    AdrChild = "Pages[" + PageChild + "]!" + NameIdChild
    HyperLinkToChild = PageChild + "/" + NameIdChild

    '��������� ������� �������� �������� � ������ ������� � ������ �� � ������ �������
    HyperLinkToParentOld = shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
    If HyperLinkToParentOld <> "" Then '���� ������ ���� - ������ �� ��������� � ��������
        '������� �������� �������� HyperLink �� ��� �������� � ��� �����
        mstrAdrParentOld = Split(HyperLinkToParentOld, "/")
        On Error GoTo netu_roditelya '����� ��� ��� ������� � ������ ������ ���������
        Set shpParentOld = ActiveDocument.Pages(mstrAdrParentOld(0)).Shapes(mstrAdrParentOld(1))
        '���� ������ � Scratch �������(��������) � ������� ���������� �������� (���������)
        For i = 1 To shpParentOld.Section(visSectionScratch).Count
            If shpParentOld.CellsU("Scratch.A" & i).ResultStr(0) = HyperLinkToChild Then
                '������ ������������ ����
                shpParentOld.CellsU("Scratch.A" & i).FormulaForceU = """""" '����� � ShapeSheet ������ �������. ���� �������� ������ ������, �� ����� NoFormula � ��������� ��������� ���������
                shpParentOld.CellsU("Scratch.C" & i).FormulaForceU = ""
                shpParentOld.CellsU("Scratch.D" & i).FormulaForceU = ""
                Exit For
            End If
        Next
    End If
netu_roditelya:
    '����������� ������� � ����� �������
    For i = 1 To shpParent.Section(visSectionScratch).Count '���� ������ �� ����������� ������ � Scratch
        If shpParent.CellsU("Scratch.A" & i).ResultStr(0) <> "" Then
            If i = shpParent.Section(visSectionScratch).Count Then '��������� ������ ���������
                '��� ��������� ����
            End If
        Else '����� ������ �� ����������� ������ � Scratch
        
            '��������� ������������ ����
            shpParent.CellsU("Scratch.A" & i).FormulaU = """" + PageChild + "/" + NameIdChild + """" ' "�����.3/Sheet.4"
            shpParent.CellsU("Scratch.C" & i).FormulaU = AdrChild + "!User.Location"   'Pages[�����.3]!Sheet.4!User.Location
            shpParent.CellsU("Scratch.D" & i).FormulaU = AdrChild + "!User.Type"  'Pages[�����.3]!Sheet.4!User.Type
            
            '��������� �������� ����
            shpChild.Cells("Prop.AutoNum").FormulaU = True '��������� � �������������
            shpChild.CellsU("User.NameParent").FormulaU = AdrParent + "!User.Name"  'Pages[�����.3]!Sheet.4!User.Name
            shpChild.CellsU("User.Number").FormulaU = AdrParent + "!Scratch.B" + CStr(i) 'Pages[�����.3]!Sheet.4!Scratch.B2
            shpChild.CellsU("User.LocationParent").FormulaU = AdrParent + "!User.Location" 'Pages[�����.3]!Sheet.4!User.Location
            
            If shpChild.CellExistsU("HyperLink.Coil", False) = False Then
               shpChild.AddNamedRow visSectionHyperlink, "Coil", 0
               shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkDescription).FormulaU = """������� ""&User.NameParent&"": ""&User.LocationParent"
            End If
            shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """" + PageParent + "/" + NameIdParent + """" ' "�����.3/Sheet.4"
            
            Exit For
        End If
    Next

End Sub

Sub DeleteChild(shpChild As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : DeleteChild - ������� �������� �������
                '���� ������� ��������, ������� ��������, ������ ��� �� ����������, � �������.
                '������� ��������� �������, ���� ��� ����
'------------------------------------------------------------------------------------------------------------
    Dim shpParent As Visio.Shape
    'Dim shpChild As Visio.Shape
    Dim vsoShape As Visio.Shape
    Dim shpThumb As Visio.Shape
    Dim colThumb As Collection
    Dim mstrAdrParent() As String
    Dim HyperLinkToParent As String
    Dim HyperLinkToChild As String
    Dim PageChild, NameIdChild As String
    Dim i As Integer
    
    Set colThumb = New Collection
    
    'Set shpChild = ActivePage.Shapes("Sheet.1") '��� �������
    
    HyperLinkToParent = shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
    
    '��������� ��� ������� �������� � �������
    If HyperLinkToParent <> "" Then
    
        '������� �������� �������� HyperLink �� ��� �������� � ��� �����
        mstrAdrParent = Split(HyperLinkToParent, "/")
        Set shpParent = ActiveDocument.Pages(mstrAdrParent(0)).Shapes(mstrAdrParent(1))
    
        PageChild = shpChild.ContainingPage.NameU
        NameIdChild = shpChild.NameID
        HyperLinkToChild = PageChild + "/" + NameIdChild
        
        '���� ������ � Scratch �������(��������) � ������� ���������� �������� (���������)
        For i = 1 To shpParent.Section(visSectionScratch).Count
            If shpParent.CellsU("Scratch.A" & i).ResultStr(0) <> HyperLinkToChild Then
                If i = shpParent.Section(visSectionScratch).Count Then '��������� ������ �� �������������
                    '�� ����� ������� � �������
                End If
            Else '����� � Scratch ����� ���������� ��������
            
                '������ ������������ ����
                shpParent.CellsU("Scratch.A" & i).FormulaForceU = """""" '����� � ShapeSheet ������ �������. ���� �������� ������ ������, �� ����� NoFormula � ��������� ��������� ���������
                shpParent.CellsU("Scratch.C" & i).FormulaForceU = ""
                shpParent.CellsU("Scratch.D" & i).FormulaForceU = ""
                
                '������� �������� ����
                'shpChild.Delete
                
                Exit For
            End If
        Next
    Else
        '������� ������� �� ��������� � ��������  - ������������� �.�. ������ ���������� � ������� vsoPagesEvent_BeforeShapeDelete
        'shpChild.Delete
        
        
    End If
    
    '�������� ��������� ���������, ���� ��� ����, � ��������� ��� ��������
    For Each vsoShape In ActivePage.Shapes
        If vsoShape.CellExistsU("User.Type", 0) Then
            If vsoShape.Cells("User.Type").Result(0) = typeThumb Then
                Set shpThumb = vsoShape
                If shpThumb.Cells("User.AdrSource").ResultStr(0) = shpChild.ContainingPage.ID & "/" & shpChild.ID Then
                    colThumb.Add shpThumb
                End If
            End If
        End If
    Next
    '������� ��������� ��������
    For Each shpThumb In colThumb
        shpThumb.Delete
    Next
    Set colThumb = Nothing
    
End Sub

Sub DeleteParent(shpParent As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : DeleteParent - ������� ������������ �������
                '������� ������ � ������������, ���� �� ��� � ������ ��������, ����� ������� ��������.
                '������� ��������� ���������, ���� ��� ����
'------------------------------------------------------------------------------------------------------------
    'Dim shpParent As Visio.Shape
    Dim shpChild As Visio.Shape
    Dim vsoShape As Visio.Shape
    Dim shpThumb As Visio.Shape
    Dim colThumb As Collection
    Dim mstrAdrChild() As String
    Dim HyperLinkToParent As String
    Dim HyperLinkToChild As String
    Dim LinkPlaceParent As String
    Dim PageParent, NameIdParent As String
    Dim i As Integer
    
    Set colThumb = New Collection
    
    'Set shpParent = ActivePage.Shapes("Sheet.6") '��� �������
    
    PageParent = shpParent.ContainingPage.NameU
    NameIdParent = shpParent.NameID
    LinkPlaceParent = PageParent + "/" + NameIdParent '��� �������� ������ � ��������

    '���� ������ � Scratch �������(��������) � �������� ��������� ��������� (��������)
    For i = 1 To shpParent.Section(visSectionScratch).Count
        HyperLinkToChild = shpParent.CellsU("Scratch.A" & i).ResultStr(0)
        If HyperLinkToChild <> "" Then '����� � Scratch ����� ���������� ��������
            
            '������� ������� �������� HyperLink �� ��� �������� � ��� �����
            mstrAdrChild = Split(HyperLinkToChild, "/")
            Set shpChild = ActiveDocument.Pages(mstrAdrChild(0)).Shapes(mstrAdrChild(1))
            '� �������� ������� ������ �� �������
            HyperLinkToParent = shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
            
            '��������� ��� ������� �������� ������ � ����� �������
            If HyperLinkToParent = LinkPlaceParent Then
                '������ �������� ����
                shpChild.CellsU("User.NameParent").FormulaU = ""
                shpChild.CellsU("User.Number").FormulaU = ""
                shpChild.CellsU("User.LocationParent").FormulaU = ""
                shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """"""
            End If
        End If
    Next
    
    '��������� ��� ��������. ������� ��������. - ������������� �.�. ������ ���������� � ������� vsoPagesEvent_BeforeShapeDelete
    'shpParent.Delete
    
    '�������� ��������� ���������, ���� ��� ����, � ��������� ��� ��������
    For Each vsoShape In ActivePage.Shapes
        If vsoShape.CellExistsU("User.Type", 0) Then
            If vsoShape.Cells("User.Type").Result(0) = typeThumb Then
                Set shpThumb = vsoShape
                If shpThumb.Cells("User.AdrSource").ResultStr(0) = shpParent.ContainingPage.ID & "/" & shpParent.ID Then
                   colThumb.Add shpThumb
                End If
            End If
        End If
    Next
    '������� ��������� ��������
    For Each shpThumb In colThumb
        shpThumb.Delete
    Next
    Set colThumb = Nothing
    
End Sub

'Sub ClearReferenceEvent(vsoShapeEvent As Visio.Shape)
''------------------------------------------------------------------------------------------------------------
'' Macros        : ClearReferenceEvent - ������ �������� ��� �����������
'                '������ ������ � �������� ��� ��� �����������.
'                '� EventDrop ������ ���� ������� = CALLTHIS("ThisDocument.ClearReferenceEvent")
'                '���� ������ ���������� � ThisDocument
''------------------------------------------------------------------------------------------------------------
'    Set vsoWindowEvent = ActiveWindow
'    Set vsoShapePaste = vsoShapeEvent
'    Click = False
'    ClearReference vsoShapePaste
'End Sub

Sub ClearReference(shpChild As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : ClearReference - ������ �������� ��� �����������
                '������ ������ � �������� ��� ��� �����������.
                '����� ���������� �������� ������� �� ����������� �������� � �������
                '� EventMultiDrop ������ ���� ������� = CALLTHIS("CrossReference.ClearReference", "SAPR_ASU")
'------------------------------------------------------------------------------------------------------------
    '������ �������� ����
    shpChild.CellsU("User.NameParent").FormulaForceU = ""
    shpChild.CellsU("User.Number").FormulaForceU = ""
    shpChild.CellsU("User.LocationParent").FormulaForceU = ""
    shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaForceU = """"""

End Sub

Sub GoHyperLink(vsoShape As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : GoHyperLink - ��������� �� ������ � ������� �������
                '��������� �� ������ � ������� ������� �� �������� �����
                
                '����� ������� � EventDblClick  =CALLTHIS("CrossReference.GoHyperLink","SAPR_ASU")
'------------------------------------------------------------------------------------------------------------
    Dim shpTarget As Visio.Shape
    Dim HyperLinkToTarget As String
    Dim mstrAdrTarget() As String
'    Dim pinLeft As Double, pinTop As Double, pinWidth As Double, pinHeight As Double '��� ���������� ���� ����
    
'    ActiveWindow.GetViewRect pinLeft, pinTop, pinWidth, pinHeight   '��������� ��� ����

    '������� ����-���� ��� ������������ ���������
    HyperLinkToTarget = vsoShape.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
    If HyperLinkToTarget <> "" Then
        mstrAdrTarget = Split(HyperLinkToTarget, "/")
        On Error GoTo netu_celi
        Set shpTarget = ActiveDocument.Pages(mstrAdrTarget(0)).Shapes(mstrAdrTarget(1))
        '��������� �� ������
        vsoShape.Hyperlinks("1").Follow
        ActiveWindow.DeselectAll
'        ActiveWindow.SetViewRect shpTarget.Cells("PinX") - pinWidth / 2, shpTarget.Cells("PinY") + pinHeight / 2, pinWidth, pinHeight
        ActiveWindow.Select shpTarget, visSelect
    End If

netu_celi:
End Sub

Sub AddReferenceWireLink(shpChild As Visio.Shape, shpParent As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : AddReferenceWireLink - ������� ����� ����� ������� �������� ��������

                '����� ������ ���������/������������� �������� ��������� ���������� ���� ��� ������� �� ���
                '����� ������� Prop.Number(5), �������� ������� Prop.Name("24V"),�������������� User.LocLink (/14.E7), ������(HyperLink="�����.3/Sheet.4"),
                '� ������ �������� ����� ���� � �������� (����� 1:1)
'------------------------------------------------------------------------------------------------------------
    'Dim shpParent As Visio.Shape
    Dim shpParentOld As Visio.Shape
    'Dim shpChild As Visio.Shape
    Dim shpChildOld As Visio.Shape
    Dim PageParent, NameIdParent, AdrParent As String
    Dim PageChild, NameIdChild, AdrChild As String
    Dim i As Integer
    Dim HyperLinkToChild As String
    Dim HyperLinkToParentOld As String
    Dim mstrAdrParentOld() As String
    Dim HyperLinkToChildOld As String
    Dim mstrAdrChildOld() As String
    
    'Set shpChild = ActivePage.Shapes("Sheet.72") '��� �������
    'Set shpParent = ActivePage.Shapes("Sheet.7") '��� �������

    PageParent = shpParent.ContainingPage.NameU
    NameIdParent = shpParent.NameID
    AdrParent = "Pages[" + PageParent + "]!" + NameIdParent
    
    PageChild = shpChild.ContainingPage.NameU
    NameIdChild = shpChild.NameID
    AdrChild = "Pages[" + PageChild + "]!" + NameIdChild
    HyperLinkToChild = PageChild + "/" + NameIdChild

    '��������� ������� �������� ������� �������(���������) � ������� �������(�����������) � ������ ��� � ������ �������.
    
    '� ��� � ������ ������ ���� ������ ��������� - ������ ��������. ��� ���� ������.
    
    HyperLinkToParentOld = shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
    If HyperLinkToParentOld <> "" Then '���� ������ ���� - ������ �� ��������� � ��������
        '������� �������� �������� HyperLink �� ��� �������� � ��� �����
        mstrAdrParentOld = Split(HyperLinkToParentOld, "/")
        On Error GoTo netu_roditelya '����� ��� ��� ������� � ������ ������ ���������
        Set shpParentOld = ActiveDocument.Pages(mstrAdrParentOld(0)).Shapes(mstrAdrParentOld(1))
        '������ ������������ ����
        shpParentOld.CellsU("User.LocLink").FormulaU = """"""
        shpParentOld.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """""" '����� � ShapeSheet ������ �������. ���� �������� ������ ������, �� ����� NoFormula � ��������� ��������� ���������
   
        
        '������� ������������ � ������ �������� �������� ���� (���� �� ����)
        HyperLinkToChildOld = shpParent.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
        If HyperLinkToChildOld <> "" Then
            mstrAdrChildOld = Split(HyperLinkToChildOld, "/")
            On Error GoTo netu_dochernego '����� ��� ��� ������� � ������ ������ ���������
            Set shpChildOld = ActiveDocument.Pages(mstrAdrChildOld(0)).Shapes(mstrAdrChildOld(1))
                
            '������ �������� ����
            shpChildOld.CellsU("Prop.Number").FormulaU = ""
            shpChildOld.CellsU("Prop.Name").FormulaU = """"""
            shpChildOld.CellsU("User.LocLink").FormulaU = """"""
            shpChildOld.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """"""
        End If
netu_dochernego:

 End If
netu_roditelya:

    '������������� � ������ ������� �������
    
    '��������� ������������ ����
    shpParent.CellsU("User.LocLink").FormulaU = AdrChild + "!User.Location"  'Pages[�����.3]!Sheet.4!User.Location
    shpParent.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """" + PageChild + "/" + NameIdChild + """" ' "�����.3/Sheet.4"
    
    '��������� �������� ����
    shpChild.CellsU("Prop.Number").FormulaU = AdrParent + "!Prop.Number"
    shpChild.CellsU("Prop.Name").FormulaU = AdrParent + "!Prop.Name"
    shpChild.CellsU("User.LocLink").FormulaU = AdrParent + "!User.Location" 'Pages[�����.3]!Sheet.4!User.Location
    shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """" + PageParent + "/" + NameIdParent + """" ' "�����.3/Sheet.4"


End Sub

Sub DeleteChildWireLink(shpChild As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : DeleteChildWireLink - ������� �������� �������
                '���� ������ ������� ��������, ������� ��������, ������ ��� �� ����������, � �������.
'------------------------------------------------------------------------------------------------------------
    Dim shpParent As Visio.Shape
    'Dim shpChild As Visio.Shape
    Dim vsoShape As Visio.Shape
    Dim mstrAdrParent() As String
    Dim HyperLinkToParent As String
    Dim i As Integer
    
    'Set shpChild = ActivePage.Shapes("Sheet.1") '��� �������
    
    HyperLinkToParent = shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
    
    '��������� ��� ������ ������� �������� ��������
    If HyperLinkToParent <> "" Then
    
        '������� �������� �������� HyperLink �� ��� �������� � ��� �����
        mstrAdrParent = Split(HyperLinkToParent, "/")
        On Error GoTo netu_roditelya '����� ��� ��� ������� � ������ ������ ���������
        Set shpParent = ActiveDocument.Pages(mstrAdrParent(0)).Shapes(mstrAdrParent(1))
            
        '������ ������������ ����
        shpParent.CellsU("User.LocLink").FormulaU = """"""
        shpParent.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """""" '����� � ShapeSheet ������ �������. ���� �������� ������ ������, �� ����� NoFormula � ��������� ��������� ���������
    
    End If
    
netu_roditelya:
    '������� �������� ���� - ������������� �.�. ������ ���������� � ������� vsoPagesEvent_BeforeShapeDelete
End Sub

Sub DeleteParentWireLink(shpParent As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : DeleteParentWireLink - ������� ������������ �������
                '������� ������ � ������������, ���� �� ��� � ������ ��������, ����� ������� ��������.
'------------------------------------------------------------------------------------------------------------
    'Dim shpParent As Visio.Shape
    Dim shpChild As Visio.Shape
    Dim vsoShape As Visio.Shape
    Dim mstrAdrChild() As String
    Dim HyperLinkToParent As String
    Dim HyperLinkToChild As String
    Dim LinkPlaceParent As String
    Dim PageParent, NameIdParent As String
    Dim i As Integer
    
    'Set shpParent = ActivePage.Shapes("Sheet.6") '��� �������
    
    PageParent = shpParent.ContainingPage.NameU
    NameIdParent = shpParent.NameID
    LinkPlaceParent = PageParent + "/" + NameIdParent '��� �������� ������ � ��������
    
        '������� ������������ �������� (����� HyperLink)
        HyperLinkToChild = shpParent.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
        If HyperLinkToChild <> "" Then '����� ����� ����������
            
            '������� �������� ���� �������� HyperLink �� ��� �������� � ��� �����
            mstrAdrChild = Split(HyperLinkToChild, "/")
            On Error GoTo netu_dochernego '����� ��� ��� ������� � ������ ������ ���������
            Set shpChild = ActiveDocument.Pages(mstrAdrChild(0)).Shapes(mstrAdrChild(1))
            '� �������� ������� ������ �� �������
            HyperLinkToParent = shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).ResultStr(0)
            
            '��������� ��� ������� �������� ������ � ����� �������
            If HyperLinkToParent = LinkPlaceParent Then
                '������ �������� ����
                shpChild.CellsU("Prop.Number").FormulaU = ""
                shpChild.CellsU("Prop.Name").FormulaU = """"""
                shpChild.CellsU("User.LocLink").FormulaU = """"""
                shpChild.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """"""
            End If
        End If
    
netu_dochernego:
'��������� ��� ��������. ������� ��������. - ������������� �.�. ������ ���������� � ������� vsoPagesEvent_BeforeShapeDelete

    
End Sub

'Sub ClearReferenceWireLinkEvent(vsoShapeEvent As Visio.Shape)
''------------------------------------------------------------------------------------------------------------
'' Macros        : ClearReferenceWireLinkEvent - ������ ��� �����������
'                '������ ������ � ��� ����������� ������� �������.
'                '� EventDrop ������ ���� ������� = CALLTHIS("ThisDocument.ClearReferenceWireLinkEvent")
'                '���� ������ ���������� � ThisDocument
''------------------------------------------------------------------------------------------------------------
'    Set vsoWindowEvent = ActiveWindow
'    Set vsoShapePaste = vsoShapeEvent
'    Click = False
'    ClearReferenceWireLink vsoShapePaste
'End Sub

Sub ClearReferenceWireLink(vsoShape As Visio.Shape)
'------------------------------------------------------------------------------------------------------------
' Macros        : ClearReferenceWireLink - ������ ��� �����������
                '������ ������ � ��� ����������� ������� �������.
                '����� ���������� �������� ������� �� ����������� �������� � �������
                '� EventMultiDrop ������ ���� ������� = CALLTHIS("CrossReference.ClearReferenceWireLink", "SAPR_ASU")
'------------------------------------------------------------------------------------------------------------
    '������ ����
    vsoShape.CellsU("Prop.Number").FormulaU = ""
    vsoShape.CellsU("Prop.Name").FormulaU = """"""
    vsoShape.CellsU("User.LocLink").FormulaU = """"""
    vsoShape.CellsSRC(visSectionHyperlink, 0, visHLinkSubAddress).FormulaU = """"""

End Sub
