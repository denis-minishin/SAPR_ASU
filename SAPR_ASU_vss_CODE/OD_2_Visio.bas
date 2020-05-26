Attribute VB_Name = "OD_2_Visio"
'------------------------------------------------------------------------------------------------------------
' Module        : OD - ����� ������
' Author        : gtfox
' Date          : 2019.09.22
' Description   : odDELL - ������� ����� ������
                ' odADD_A3 - ��������� ����� ������ �� ������ �3, � ���� �� ������� �� ��������� �3 - ��������� �4
                ' odADD_A4 - ��������� ����� ������ �� ������ ������ �4.
                ' OD_2_Visio.doc - ����� ������ (��������� ����� �������) - �������� �������� �����, ������� ����� ������� �� ����� � �������� � ������ Visio ��� ������ �������.
                ' � ���������� ��� ������ ��������� OD_2_Visio_Split.doc (� ���������� �� ������������ + ���������������� ��� ������ ������ �������)
                ' �� ����, � �������� ���������� ����� ������, ������ ������ ��. ����������� �������/������ ������� ����� ������ (����� ��� ��������� ���� ����������� ������ ����� - ������ �� ������������ ����). ��������� ������ odADD_�3 / odADD_�4
                ' �������� �������� ��������� ������ � Visio � ���������� ������������ ������ �� ����� ��������/����� ����, � ����� ��� ����������� ���������� � ��������� ������� ������.
                ' � ����� ��������� ��� ������ �� Word. ���� ������� ����� �� �� ������ ���� � Word, ������ ����� ��� ����������� � �� �������� ���������� �������� � ����, ����� ��������� ������ ������� � �� ��������� �������� ������ ����� ���� ��� ������ ����� ��.
' Link          : https://visio.getbb.ru/viewtopic.php?p=14130, https://yadi.sk/d/24V8ngEM_8KXyg
'------------------------------------------------------------------------------------------------------------
    
    
Public Sub odADD_A4()
    OD_2_Visio (1)
End Sub

Public Sub odADD_A3()
    OD_2_Visio (0)
End Sub

    
Private Sub OD_2_Visio(A4 As Boolean)
    '������ ���� � ����� ��� ����� � �����
    Const ramka5 = 1
    Const ramka15 = 2.5
    Const ramka55 = 6.5
    nA3 = 1

    Dim vsoCharacters1 As Visio.Characters
    Dim oStartPage As Range
    Dim oEndPage As Range
    Dim nStartPageNum As Long
    Dim nPagesCount As Long
    Dim nEndPageNum As Long
    Dim sPath, sFile As String
    Dim objFSO As Object, objFile As Object
    Dim MastOD As Master
    Set MastOD = Application.Documents.Item("SAPR_ASU_SHAPE.vss").Masters.ItemU("��")

    
    
    
    If Not Application.ActiveWindow.Selection.Count = 0 Then
    
        If InStr(1, Application.ActiveWindow.Selection.Item(1).Name, "��") > 0 Then
            
            Set vsoCharacters1 = Application.ActiveWindow.Selection.Item(1).Characters
            
            '���� ����
            sPath = Visio.ActiveDocument.Path
            sFileName = "OD_2_Visio.doc"
            sFile = sPath & sFileName
            If Dir(sFile, 16) = "" Then
                MsgBox "���� " & sFileName & " �� ������ � �����: " & sPath, vbCritical, "������"
                Exit Sub
            End If
            
            '�������������� �����������
            Set objFSO = CreateObject("Scripting.FileSystemObject")
            Set objFile = objFSO.GetFile(sFile)
    
            '������� ������
            sFileName = "OD_2_Visio_Split.doc"
            sFile = sPath & sFileName
            If Len(Dir(sFile)) > 0 Then '���� ���� �� ���� ����
                'On Error GoTo L1
                Kill sFile
            End If
            
            '�������� ���� � ����� ������
            objFile.Copy sFile
            
            '��������������� �����
            'Name sPath & "�� - �����.doc" As sFile
    
            Set wa = CreateObject("Word.Application")
            wa.Documents.Open (sFile)
            wa.Visible = True
            Set wad = wa.ActiveDocument
      
            wa.Selection.WholeStory '�������� ���
     
            DoEvents
     
            With wa.Selection.Font
                .Name = "ISOCPEUR"
                .Size = 14
                .Bold = False
                .Italic = True
                .Underline = wdUnderlineNone
                .UnderlineColor = wdColorAutomatic
                .Strikethrough = False
                .DoubleStrikeThrough = False
                .Outline = False
                .Emboss = False
                .Shadow = False
                .Hidden = False
                .SmallCaps = False
                .AllCaps = False
                .Color = wdColorAutomatic
                .Engrave = False
                .Superscript = False
                .Subscript = False
                .Spacing = 0
                .Scaling = 100
                .Position = 0
                .Kerning = 0
                .Animation = wdAnimationNone
            End With
            
            DoEvents
            
            With wa.Selection.ParagraphFormat
                .LeftIndent = CentimetersToPoints(0)
                .RightIndent = CentimetersToPoints(0)
                .SpaceBefore = 5
                .SpaceBeforeAuto = False
                .SpaceAfter = 0
                .SpaceAfterAuto = False
                .LineSpacingRule = wdLineSpaceMultiple
                .LineSpacing = LinesToPoints(1) '������������� ��������
                .Alignment = wdAlignParagraphJustify
                .WidowControl = True
                .KeepWithNext = False
                .KeepTogether = False
                .PageBreakBefore = False
                .NoLineNumber = False
                .Hyphenation = True
                .FirstLineIndent = CentimetersToPoints(1)
                .OutlineLevel = wdOutlineLevelBodyText
                .CharacterUnitLeftIndent = 0
                .CharacterUnitRightIndent = 0
                .CharacterUnitFirstLineIndent = 0
                .LineUnitBefore = 0
                .LineUnitAfter = 0
                .MirrorIndents = False
                .TextboxTightWrap = wdTightNone
            End With
            
            DoEvents
            
            With wa.Selection.PageSetup
                .LineNumbering.Active = False
                .Orientation = wdOrientLandscape
                .TopMargin = CentimetersToPoints(1)
                .LeftMargin = CentimetersToPoints(2.5)
                .RightMargin = CentimetersToPoints(1)
                '.BottomMargin = CentimetersToPoints(1) '����� 5
                .BottomMargin = CentimetersToPoints(2.5) '����� 15
                '.BottomMargin = CentimetersToPoints(6.5) '����� 55
                .Gutter = CentimetersToPoints(0)
                .HeaderDistance = CentimetersToPoints(0)
                .FooterDistance = CentimetersToPoints(0)
                .PageWidth = CentimetersToPoints(21)
                .PageHeight = CentimetersToPoints(29.7)
                .FirstPageTray = wdPrinterDefaultBin
                .OtherPagesTray = wdPrinterDefaultBin
                .SectionStart = wdSectionNewPage
                .OddAndEvenPagesHeaderFooter = False
                .DifferentFirstPageHeaderFooter = False
                .VerticalAlignment = wdAlignVerticalTop
                .SuppressEndnotes = False
                .MirrorMargins = False
                .TwoPagesOnOne = False
                .BookFoldPrinting = False
                .BookFoldRevPrinting = False
                .BookFoldPrintingSheets = 1
                .GutterPos = wdGutterPosLeft
            End With
            
            '��������� �� ������ � �����
    '        Application.ActiveWindow.Selection.Item(1).CellsSRC(visSectionTab, 0, visTabStopCount).FormulaU = "1"
    '        Application.ActiveWindow.Selection.Item(1).CellsSRC(visSectionTab, 0, visTabPos).FormulaU = "Guard(92.5 mm)"
    '        Application.ActiveWindow.Selection.Item(1).CellsSRC(visSectionTab, 0, visTabAlign).FormulaU = "Guard(1)"
    '        Application.ActiveWindow.Selection.Item(1).CellsSRC(visSectionTab, 0, 3).FormulaU = "0"
            
            
            '��������� �� ������ � �����
            wa.Selection.ParagraphFormat.TabStops.Add Position:=CentimetersToPoints(9.25), Alignment:=wdAlignTabCenter, Leader:=wdTabLeaderSpaces '��������� �� ������
            
            
            hh = Application.ActiveWindow.Selection.Item(1).Cells("Height") ' ������ ������� ����� ������ � �����
            niznee_pole = 297 - 10 - hh * 25.4  '������ ���� �� �������� � ����� � �� (��� ������� �������)
            
    
            '���� ������� 1
            wa.Selection.GoTo What:=wdGoToPage, Which:=wdGoToAbsolute, Name:="1"
            wa.Selection.PageSetup.BottomMargin = CentimetersToPoints(niznee_pole / 10) '������ ������ ���� � ��
            
            nStartPageNum = 1
            Set oStartPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum)
            nEndPageNum = 1
            '����� ��������� �������� ��� ���������
            Set oEndPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum + nEndPageNum)  '.GoToNext(wdGoToPage)
            '�������� ��������� �������� ���������
            wad.Range(oStartPage.Start, oEndPage.End).Select ' wad.Range(oStartPage.Start, IIf(nStartPageNum + nEndPageNum = nPagesCount + 1, wad.Range.End, oEndPage.End)).Select
            '�������� � ����� � �����
            wa.Selection.Copy
            '��������� �� ������ � �����
            ActiveWindow.SelectedText.Paste
            '�������� ����� ������
            ActivePage.Shapes.Item("��").Cells("Geometry1.NoLine").Formula = 1
            
            '��������� � ������ 2-�� ����� �����
            wa.Selection.GoTo What:=wdGoToPage, Which:=wdGoToAbsolute, Name:="2"
            wa.Selection.MoveEnd wdCharacter, -1 '��� ����� - ����� ���������� ��������
            wa.Selection.InsertBreak Type:=wdSectionBreakNextPage '������� ������ �������
            
            '������ ���� ��� ����� 15 ����� ����� ������ �������� ����� for ����� "�����/�����" �������� ����� ������
            niznee_pole = ramka15
            wa.Selection.PageSetup.BottomMargin = CentimetersToPoints(niznee_pole) '������ ������ ���� � ��
            
            nPagesCount = wad.Range.ComputeStatistics(wdStatisticPages) '����� ������ �����
            nPagesOst = nPagesCount - 1
            pNumberVisio = 1
            
            For CurPage = 2 To nPagesCount
                '��������� �� ���� �������� �����
                wa.Selection.GoTo What:=wdGoToPage, Which:=wdGoToAbsolute, Name:=CurPage
    
                If nPagesOst = 1 Or A4 Then '��������� ���� ��� ������� "��� ����� �4"
                
                    '������ ���� � ����� ��� ����� ����� visio
                    niznee_pole = ramka15
                    wa.Selection.PageSetup.BottomMargin = CentimetersToPoints(niznee_pole) '������ ������ ���� � ��
                    '��������� ���� �4
                    Set aPage = AddNamedPageOD("��." & pNumberVisio + 1)
                    aPage.Index = 2 + pNumberVisio '���� �������� �� ������� ������ ��
                    pNumberVisio = pNumberVisio + 1
                    ActivePage.PageSheet.Cells("PageWidth").Formula = "210 MM"
                    ActivePage.PageSheet.Cells("PageHeight").Formula = "297 MM"
                    ActivePage.PageSheet.Cells("Paperkind").Formula = 9
                    ActivePage.PageSheet.Cells("PrintPageOrientation").Formula = 1
                    ActivePage.Drop MastOD, 6.889764, 8.661417
                    '�������� ����� ������
                    ActiveWindow.Selection.Item(1).Cells("Geometry1.NoLine").Formula = 1
                    '�������� ������ ��� ����������� ������� ������
                    'shpOD.Paste '.Select '���� ���� ���� ����� paste �����
                    '������� �������� �������� �����
                    nStartPageNum = CurPage
                    Set oStartPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum)
                    nEndPageNum = CurPage
                    '����� ��������� �������� ��� ���������
                    Set oEndPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum + 1)  '.GoToNext(wdGoToPage)
                    '�������� ��������� �������� ���������
                    wad.Range(oStartPage.Start, IIf(nStartPageNum = nPagesCount, wad.Range.End, oEndPage.End)).Select 'wad.Range(oStartPage.Start, oEndPage.End).Select '
                    '�������� � ����� � �����
                    wa.Selection.Copy
                    
                    If Not nStartPageNum = nPagesCount Then
                        oEndPage.InsertBreak Type:=wdSectionBreakNextPage '������� ������ �������
                    End If

    
                    DoEvents
                    'shpOD.Paste
                    '��������� �� ������ � �����
                    ActiveWindow.SelectedText.Paste
                    
                    '���������� ����� ������� �����
                    nPagesOst = nPagesCount - CurPage
    
                ElseIf nPagesOst >= 2 Then   '������ ������ 2-� ��������� �3
                    
                    If nA3 = 1 Then ' ����� �������� �3
                    
                        '������ ���� � ����� ��� ����� ����� visio
                        niznee_pole = ramka5
                        wa.Selection.PageSetup.BottomMargin = CentimetersToPoints(niznee_pole) '������ ������ ���� � ��
                        '��������� ���� �3
                        Set aPage = AddNamedPageOD("��." & pNumberVisio + 1)
                        aPage.Index = 2 + pNumberVisio '���� �������� �� ������� ������ ��
                        ActivePage.PageSheet.Cells("PageWidth").Formula = "420 MM"
                        ActivePage.PageSheet.Cells("PageHeight").Formula = "297 MM"
                        ActivePage.PageSheet.Cells("Paperkind").Formula = 8
                        ActivePage.PageSheet.Cells("PrintPageOrientation").Formula = 2
                        ActivePage.Drop MastOD, 6.889764, 8.661417
                        With ActiveWindow.Selection.Item(1) '�������� �� �����
                            .Cells("Geometry1.NoLine").Formula = 1 '�������� ����� ������
                            .Cells("PinX").FormulaForceU = "=GUARD((25 mm-TheDoc!User.OffsetFrame)/ThePage!PageScale*ThePage!DrawingScale)"
                            .Cells("PinY").FormulaForceU = "(ThePage!PageHeight-TheDoc!User.OffsetFrame)/ThePage!PageScale*ThePage!DrawingScale"
                            .Cells("Height").FormulaForceU = "=ThePage!PageHeight-TheDoc!User.OffsetFrame*2"
                            .Cells("Actions.right.Invisible").Formula = 0
                            .Cells("Actions.left.Invisible").Formula = 1
                        End With

                        '������� �������� �������� �����
                        nStartPageNum = CurPage
                        Set oStartPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum)
                        nEndPageNum = CurPage
                        '����� ��������� �������� ��� ���������
                        Set oEndPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum + 1)  '.GoToNext(wdGoToPage)
                        '�������� ��������� �������� ���������
                        wad.Range(oStartPage.Start, IIf(nStartPageNum = nPagesCount, wad.Range.End, oEndPage.End)).Select 'wad.Range(oStartPage.Start, oEndPage.End).Select '
                        '�������� � ����� � �����
                        wa.Selection.Copy
                        
                        If Not nStartPageNum = nPagesCount Then
                            oEndPage.InsertBreak Type:=wdSectionBreakNextPage '������� ������ �������
                        End If

                        DoEvents
                        '��������� �� ������ � �����
                        ActiveWindow.SelectedText.Paste
                        nA3 = 2
                        
                    ElseIf nA3 = 2 Then ' ������ �������� �3
                        
                        '������ ���� � ����� ��� ����� ����� visio
                        niznee_pole = ramka15
                        wa.Selection.PageSetup.BottomMargin = CentimetersToPoints(niznee_pole) '������ ������ ���� � ��
                        pNumberVisio = pNumberVisio + 1
                        ActivePage.Drop MastOD, 6.889764, 8.661417
                        '�������� ����� ������
                        ActiveWindow.Selection.Item(1).Cells("Geometry1.NoLine").Formula = 1
                        '������� �������� �������� �����
                        nStartPageNum = CurPage
                        Set oStartPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum)
                        nEndPageNum = CurPage
                        '����� ��������� �������� ��� ���������
                        Set oEndPage = wad.Range.GoTo(wdGoToPage, wdGoToAbsolute, nStartPageNum + 1)  '.GoToNext(wdGoToPage)
                        '�������� ��������� �������� ���������
                        wad.Range(oStartPage.Start, IIf(nStartPageNum = nPagesCount, wad.Range.End, oEndPage.End)).Select 'wad.Range(oStartPage.Start, oEndPage.End).Select '
                        '�������� � ����� � �����
                        wa.Selection.Copy
                        
                        If Not nStartPageNum = nPagesCount Then
                            oEndPage.InsertBreak Type:=wdSectionBreakNextPage '������� ������ �������
                        End If

                        DoEvents
                        '��������� �� ������ � �����
                        ActiveWindow.SelectedText.Paste
                        nA3 = 1
                        '���������� ����� ������� �����
                        nPagesOst = nPagesCount - CurPage
                        
                        
                    End If
                    
                ElseIf nPagesOst <= 0 Then '������ ������ ���
                    
                End If
                
                nPagesCount = wad.Range.ComputeStatistics(wdStatisticPages) '����� ������ �����

                
            Next CurPage
            
            wad.Close SaveChanges:=True
            wa.Quit
            Set wa = Nothing
            
            Application.ActiveWindow.Page = Application.ActiveDocument.Pages.Item("��")

            MsgBox "��������� ����� �� ���������", vbInformation
            Exit Sub
                            
        End If

    End If
    
    MsgBox "�� ������� ���� ��", vbCritical, "������"
    
    Exit Sub
    
'        wa.Selection.Start = wa.Selection.Start - 1
'        wa.Selection.End = wa.Selection.Start
'        wa.Selection.HomeKey Unit:=wdStory '���� ����������
'        wa.Selection.GoToNext (wdGoToPage) '������ ��������� ��������
'        wa.Selection.MoveEnd wdCharacter, -1 '��� ����� - ����� ���������� ��������
'        wa.Selection.InsertBreak Type:=wdSectionBreakNextPage '������� ������ �������
'        nPagesCount = wad.Range.ComputeStatistics(wdStatisticPages) '����� ������ �����
'With wa.ActiveDocument
'Set Search = .Range(Start:=0, End:=100) '��� ����� �� �������� ���� ��������
'Search.Select
'wa.Selection.Find.Execute FindText:="��������� �����", Forward:=True
L1:
        MsgBox "���� " & sFile & " ����� � �� ����� ���� ������", vbCritical, "������"
End Sub


Function AddNamedPageOD(pName As String) As Visio.Page
    Dim aPage As Visio.Page
    Dim Ramka As Visio.Master
    Set aPage = ActiveDocument.Pages.Add
    aPage.Name = pName
    
    Set Ramka = Application.Documents.Item("SAPR_ASU_SHAPE.vss").Masters.Item("�����")  'ActiveDocument.Masters.Item("�����")
    Set sh = ActivePage.Drop(Ramka, 0, 0)
    'ActivePage.Shapes(1).Cells("fields.value").FormulaU = "=TheDoc!User.dec & "".CO"""
    '������ ������� "=pagenumber()-thedoc!user.coc"
'    ActivePage.Shapes(1).Shapes("FORMA3").Shapes("shifr").Cells("fields.value").FormulaU = "=TheDoc!User.dec & "".CO"""
'    ActivePage.Shapes(1).Shapes("FORMA3").Shapes("list").Cells("fields.value").FormulaU = "=PAGENUMBER()+Sheet.1!Prop.CNUM + TheDoc!User.coc - PAGECOUNT()"
'    ActivePage.Shapes(1).Shapes("FORMA3").Shapes("listov").Cells("fields.value").FormulaU = "=TheDoc!User.coc"
    ActivePage.Shapes(1).Cells("user.n.value") = 6
    ActivePage.Shapes(1).Cells("Prop.cnum.value") = 0
    ActivePage.Shapes(1).Cells("Prop.tnum.value") = 0
    
    Set AddNamedPageOD = aPage
End Function

Public Sub odDELL()
    Dim dp As Page
    Dim colPage As Collection
    Set colPage = New Collection
    '�������� ��� �������� � ��������� � ��������� ���� ������ (���� ������� ����� ��� ��, �� 3-� �������� ���������� 2-�, � 2-� for each ��� ��������� :) ������ )
    For Each dp In ActiveDocument.Pages
        If InStr(1, dp.Name, "��.") > 0 Then
            colPage.Add dp
        End If
    Next
    '������� ��� �������� ������� ����� ����
    For Each dp In colPage
        dp.Delete (1)
    Next
    Set colPage = Nothing
    Application.ActiveWindow.Page = Application.ActiveDocument.Pages.Item("��")
    MsgBox "����� �� �������", vbInformation
End Sub



