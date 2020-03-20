unit TestRegistry;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, jpeg, ComCtrls, StdCtrls, Gauges, Settings,
  RegFilesCollection, ImgList, Defrag, DateUtils, VMan, Register, RestorePoint,
  Buttons, ShellAPI;

const
 //Indicator consts
  IDWidth = 30; //480 px
  IDHeight = 10; //160 px
  IDSize = IDWidth * IDHeight;

  Analised: boolean = false;
type
  TTestRegistryForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    StatusBar1: TStatusBar;
    Panel6: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    Label7: TLabel;
    Panel7: TPanel;
    Panel8: TPanel;
    ListView1: TListView;
    Image9: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image13: TImage;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Image14: TImage;
    Image15: TImage;
    Gauge1: TGauge;
    ImageList1: TImageList;
    Label15: TLabel;
    ImageList2: TImageList;
    Panel9: TPanel;
    SpeedButton1: TSpeedButton;
    Image18: TImage;
    Label2: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Image17: TImage;
    Label4: TLabel;
    Image19: TImage;
    Panel10: TPanel;
    Panel11: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label14: TLabel;
    Image20: TImage;
    procedure FormShow(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListView1CustomDrawSubItem(Sender: TCustomListView; Item: TListItem; SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure DrawIndicatior(Number, Item: integer);
    procedure ResetIndicatior;
    procedure StartTest;
    procedure StartDefrag;
    procedure DefragProcess(var Message: TMessage); message WM_DefragProcess;
    procedure FormActivate(Sender: TObject);
    procedure DrawMap(Map: string);
    procedure Label2Click(Sender: TObject);
    procedure Label2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Panel9MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Label16Click(Sender: TObject);
    procedure PutLabelInfo;
    procedure FormCreate(Sender: TObject);
    procedure ShowWait(WCaption, WMessage: string);
    procedure HideWait;
  private
  public
    Mode: TDefragFileMode;
  end;

var
  TestRegistryForm: TTestRegistryForm;
  RegMap: string;
  BreakOperation: boolean = True;
implementation
uses Main;
{$R *.dfm}
var
  StartTime: dword;
  AnaliseInProcess: boolean = False;
  ItemPosition: integer;
  AnaliseMap: string;
  BackupMap: string;
  BusyDraw: boolean = False;

  AnalysedCount: dword;
  AnalysedSize: dword;
  AnalysedNewSize: dword;
  AnalyseTime: dword;
  AnalyseEstimateTime: dword;
  AnalysePercent: word;

  CurName: string;
  CurSize: dword;
  CurTime: dword;



procedure TTestRegistryForm.FormShow(Sender: TObject);
var
  ListItem: TListItem;
  i: integer;
begin
  if Analised then Exit;
  ListView1.Clear;
  for i := 0 to HivePath.Count - 1 do
  begin
    ListItem := ListView1.Items.Add;
    ListItem.Caption := RegKeysList[i];
    ListItem.SubItems.Add(StringToDotString(IntToStr(Integer(HivePath.Objects[i]))));
    ListItem.SubItems.Add('?');
    ListItem.SubItems.Add('?');
    ListItem.ImageIndex := 0;

    ListItem := ListView1.Items.Add;
    ListItem.Caption := HivePath[i];
    ListItem.Indent := 1;
    ListItem.ImageIndex := -1;
  end;

  Gauge1.Progress := 0;
  Gauge1.MaxValue := HivePath.Count - 1;

  Label7.Caption := '';

  PutLabelInfo;
  ResetIndicatior;


end;

procedure TTestRegistryForm.ListView1CustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if Item.Index and 1 > 0 then
    TListView(Sender).Canvas.Brush.Color := $00F4F4F4;

  if Item.Indent = 0 then TListView(Sender).Canvas.Font.Style := [fsBold]
  else TListView(Sender).Canvas.Font.Color := clGray;

end;

procedure TTestRegistryForm.ListView1CustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Item.Index and 1 > 0 then
    TListView(Sender).Canvas.Brush.Color := $00F4F4F4;
end;

procedure TTestRegistryForm.DrawIndicatior(Number, Item: integer);
var
  BitMap: TBitMap;
  R1, R2: TRect;

  function LengToXY(Len: integer): TPoint;
  begin
    result.Y := Len div IDWidth;
    result.X := len - result.Y * IDWidth;
  end;

begin
  BitMap := TBitMap.Create;
  ImageList1.GetBitmap(Item, BitMap);
  R1 := BitMap.Canvas.ClipRect;
  R2 := R1;
  R1.Left := LengToXY(Number).X * 16;
  R1.Top := LengToXY(Number).Y * 16;
  R1.Right := R1.Left + 16;
  R1.Bottom := R1.Top + 16;
  Image9.Canvas.CopyRect(R1, BitMap.Canvas, R2);
  BitMap.Free;
end;

procedure TTestRegistryForm.ResetIndicatior;
var
  i: integer;
begin
  for i := 0 to IDSize do
    DrawIndicatior(i, 0);
end;

//------------------------------------------------------------------------------

procedure TTestRegistryForm.StartTest;
var
  CriticalSection: TRTLCriticalSection;
  RestorePoint: Comp;
  i, j, l, k: integer;
  CSize, CNewSize: System.int64;
  ASize, ANewSize: dword;
  Time: dword;
begin

    if MessageDlg(GetLKey('DoDefrag'), mtInformation, mbOKCancel, 0) = mrCancel then
     begin
      Close;
      Exit;
     end;

  AnaliseInProcess := True;
  BreakOperation := False;
  SpeedButton1.Caption := GetLKey('Stop');
  try
    if not Analised then
    begin

      InitializeCriticalSection(CriticalSection);

      Label1.Caption := GetLKey('RegAnalyses');
      MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);

      NewAllFilesSize := 0;
      SetLength(RegMap, 0);
      CSize := 0;
      Label7.Caption := '';
      Gauge1.Visible := True;
      Label7.Visible := True;

      AnalysedCount := 0;
      AnalysedSize := 0;
      AnalysedNewSize := 0;
      AnalyseTime := 0;
      AnalyseEstimateTime := 0;
      AnalysePercent := 0;

      CurName := '';
      CurSize := 0;
      CurTime := 0;

      StartTime := GetTickCount;

      for i := 0 to HivePath.Count - 1 do
      begin
        Time := GetTickCount;
        ListView1.Items[i * 2].Selected := True;
        ListView1.Items[i * 2].MakeVisible(True);

        CurSize := GetFileSize(HivePath[i]);
        CSize := Trunc(CurSize / (AllSize / (IDSize))) + 1;
        SetLength(AnaliseMap, CSize);
        FillChar(AnaliseMap[1], CSize, '?');

        AnaliseMap := RegMap + AnaliseMap;
        DrawMap(AnaliseMap);

        CurName := RegKeysList[i];

        CurTime := 0;

        PutLabelInfo;

        CurTime := GetTickCount;

        Gauge1.Progress := i;

        if BreakOperation then Break;
        TestRegFile(i, Handle, ASize, ANewSize);

        CurTime := GetTickCount - CurTime;

        Time := (GetTickCount - Time) div 1000;

        AnalysedCount := AnalysedCount + 1;
        AnalysedSize := AnalysedSize + ASize;
        AnalysedNewSize := AnalysedNewSize + ANewSize;
        AnalyseTime := AnalyseTime + Time;
        if AnalyseTime = 0 then
        begin
          AnalyseTime := 1;
          AnalyseEstimateTime := 0;
        end
        else
        try
          AnalyseEstimateTime := Trunc((AllSize - AnalysedSize) / (AnalysedSize / AnalyseTime)) + AnalyseTime;
        except
          AnalyseEstimateTime := 0; // :(
        end;
        AnalysePercent := 100 - Trunc(AnalysedNewSize / (AnalysedSize / 100));
        PutLabelInfo;


    //Out to list

        ListView1.Items[i * 2].SubItems[1] := StringToDotString(IntToStr(ANewSize));

        if Time > 0 then
          ListView1.Items[i * 2].SubItems[2] := StringToDotString(IntToStr(Time)) + ' sec'
        else
          ListView1.Items[i * 2].SubItems[2] := '< 1 sec';

    //Draw map
        CNewSize := Trunc(ANewSize / (AllSize / (IDSize))) + 1;

        if (CSize > 5) and (CNewSize = CSize) then CNewSize := CNewSize - Random(5) - 1;

        SetLength(AnaliseMap, CSize);
        FillChar(AnaliseMap[1], CSize, ' ');
        j := 1;
        repeat
          k := random(length(AnaliseMap) - 1) + 1;
          for l := k to length(AnaliseMap) do
            if AnaliseMap[l] = ' ' then
            begin
              AnaliseMap[l] := '1';
              j := j + 1;
              break;
            end;
        until (j > CNewSize) or (k = length(AnaliseMap));

        RegMap := RegMap + AnaliseMap;
        DrawMap(RegMap);
      end;

      if not BreakOperation then
      begin
        Gauge1.Visible := False;
        Label7.Visible := False;

        CSize := 100 - Trunc(NewAllFilesSize / (AllSize / 100));

        Label15.Caption := IntToStr(CSize) + '% ' + GetLKey('Unfragment');
        Label3.Caption := GetLKey('AnaliseComplete');

        MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);

        Label15.Visible := True;
      end
      else
      begin
        Label1.Caption := GetLKey('AnaliseAborted');
        MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);
      end;
      SetMKey('LastAnalyse', DateTimeToStr(Now));
      SetMKey('AnalyseTime', IntToStr(AnalyseTime));
      SetMKey('UnfragSize', IntToStr(AnalysedSize));
      SetMKey('DefragSize', IntToStr(AnalysedNewSize));
      SetMKey('LastPercent', IntToStr(AnalysePercent));
      Analised := not BreakOperation;
    end;
  except
  end;
  AnaliseInProcess := False;
  CurName := '';
  CurSize := 0;
  CurTime := 0;
  PutLabelInfo;
  Settings.ResetConfig;
  MainForm.SetStatistics;
  HideWait;
  SpeedButton1.Caption := GetLKey('Close');
  if BreakOperation then Close;

end;

//------------------------------------------------------------------------------

procedure TTestRegistryForm.StartDefrag;
var
  CriticalSection: TRTLCriticalSection;
  IRestorePoint: RestorePoint.Int64;
  i, j, l, k: integer;
  CSize, CNewSize: System.int64;
  ASize, ANewSize: dword;
  Time: dword;
begin


  SpeedButton1.Caption := GetLKey('Stop');
  if (GetRegisterStatus <> -1) and (GetMKey('LastDefrag')[1] <> '%') then Exit;
  Label15.Caption := '';

  StartTest;

  if BreakOperation then Exit;

  AnaliseInProcess := True;
  BreakOperation := False;

  ListView1.Items[0].Selected := True;
  ListView1.Items[0].MakeVisible(True);

  Gauge1.Progress := 0;
  Gauge1.Visible := True;
  Label7.Visible := True;

  AnalysedCount := 0;
  AnalysedSize := 0;
  AnalysedNewSize := 0;
  AnalyseTime := 0;
  AnalyseEstimateTime := 0;
  AnalysePercent := 0;

  CurName := '';
  CurSize := 0;

  try
    InitializeCriticalSection(CriticalSection);

    if StrToBoolDef(GetMKey('CreatBackup'), True) then
    begin
      Label1.Caption := GetLKey('RegBackup');
      MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);
      ShowWait(GetLKey('BackupCaption'), GetLKey('BackupMessage'));
      Begin_restore(IRestorePoint, WideString('Registry Defrag 2010 Restore Point at ' + DateTimeToStr(Now)));
      HideWait;
    end;

    Label1.Caption := GetLKey('RegDefrag');
    MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);

    NewAllFilesSize := 0;
    CSize := 0;
    Label7.Caption := '';

    Gauge1.Visible := True;
    Label7.Visible := True;
    RegMap := '';

    Label3.Caption := GetLKey('DefragProcess');

    StartTime := GetTickCount;


    for i := 0 to HivePath.Count - 1 do
    begin
      Time := GetTickCount;
      ListView1.Items[i * 2].Selected := True;
      ListView1.Items[i * 2].MakeVisible(True);

      CurSize := GetFileSize(HivePath[i]);
      CSize := Trunc(CurSize / (AllSize / (IDSize))) + 1;
      SetLength(AnaliseMap, CSize);
      FillChar(AnaliseMap[1], CSize, '?');

      AnaliseMap := RegMap + AnaliseMap;
      DrawMap(AnaliseMap);

      CurName := RegKeysList[i];

      CurTime := 0;

      PutLabelInfo;

      CurTime := GetTickCount;

      Gauge1.Progress := i;

      if BreakOperation then Break;
      DefragRegFile(i, Handle, ASize, ANewSize);

      CurName := RegKeysList[i];

      CurTime := 0;

      PutLabelInfo;

      CurTime := GetTickCount;

      Gauge1.Progress := i;

      Time := (GetTickCount - Time) div 1000;

      AnalysedCount := AnalysedCount + 1;
      AnalysedSize := AnalysedSize + ASize;
      AnalysedNewSize := AnalysedNewSize + ANewSize;
      AnalyseTime := AnalyseTime + Time;
      if AnalyseTime = 0 then
      begin
        AnalyseTime := 1;
        AnalyseEstimateTime := 0;
      end
      else
      try
        AnalyseEstimateTime := Trunc((AllSize - AnalysedSize) / (AnalysedSize / AnalyseTime)) + AnalyseTime;
      except
        AnalyseEstimateTime := 0; // :(
      end;
      AnalysePercent := 100 - Trunc(AnalysedNewSize / (AnalysedSize / 100));

    //Out to list
      ListView1.Items[i * 2].SubItems[1] := StringToDotString(IntToStr(ANewSize));


      if Time > 0 then
        ListView1.Items[i * 2].SubItems[2] := StringToDotString(IntToStr(Time)) + ' sec'
      else
        ListView1.Items[i * 2].SubItems[2] := '< 1 sec';


    //Draw map
      CNewSize := Trunc(ANewSize / (AllSize / (IDSize))) + 1;
      if (CSize > 5) and (CNewSize = CSize) then CNewSize := CNewSize - Random(5) - 1;

      SetLength(AnaliseMap, CSize);
      FillChar(AnaliseMap[1], CSize, '2');
      FillChar(AnaliseMap[1], CNewSize, '0');
      RegMap := RegMap + AnaliseMap;
      DrawMap(RegMap);
    end;

    if not BreakOperation then
    begin
      Gauge1.Visible := False;
      Label7.Visible := False;

      CSize := 100 - Trunc(NewAllFilesSize / (AllSize / 100));

      Label15.Caption := GetLKey('RebootSystem');

      MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);
      Label15.Visible := True;

      SetMKey('LastDefrag', DateTimeToStr(Now));
      SetMKey('DefragSize', IntToStr(AnalysedNewSize));
      SetMKey('LastPercent', '0');


      if MessageDlg(GetLKey('DefragComplete'), mtInformation, mbOKCancel, 0) = mrOK then
      begin
        if not ExitWindowsEx(EWX_REBOOT or EWX_FORCE, 0) then
          ShowMessage(GetLKey('CantReboot'));
      end;

      Halt(1);
    end
    else
    begin
      Label1.Caption := GetLKey('DefragAborted');
      MainForm.AdjustLabels(Label1, Label15, nil, nil, nil, nil);

    end;

    Analised := not BreakOperation;
  except
  end;
  AnaliseInProcess := False;
  Self.Close;
  HideWait;
  SpeedButton1.Caption := GetLKey('Close');
  if BreakOperation then Close;
end;

procedure TTestRegistryForm.DefragProcess(var Message: TMessage);
begin
  Label7.Caption := GetLKey('AnaliseTime') + ' ' + StringToDotString(IntToStr((GetTickCount - StartTime) div 1000)) + ' sec';
  Label20.Caption := GetLKey('CutTime') + ' ' + StringToDotString(IntToStr((GetTickCount - CurTime) div 1000)) + ' ' + ' sec';
  DrawMap(AnaliseMap);
  //------------

  if AnalyseTime = 0 then
  begin
    AnalyseTime := 1;
    AnalyseEstimateTime := 0;
  end
  else
  try
    AnalyseEstimateTime := Trunc((AllSize - AnalysedSize) / ((AnalysedSize + CurSize) / (AnalyseTime + (GetTickCount - CurTime) div 1000))) + AnalyseTime;
  except
    AnalyseEstimateTime := 0; // :(
  end;


  if AnalyseEstimateTime <> 0 then
    Label27.Caption := GetLKey('AnalyseTime') + ' ' + StringToDotString(IntToStr(AnalyseTime)) + ' ' +
      GetLKey('SecFor') + ' ' + StringToDotString(IntToStr(AnalysedCount)) + ' ' +
      GetLKey('EstimateTime') + ' ' + StringToDotString(IntToStr(AnalyseEstimateTime)) + ' ' + GetLKey('AllFiles')
  else
    Label27.Caption := GetLKey('AnalyseTime') + ' ' + StringToDotString(IntToStr(AnalyseTime)) + ' ' +
      GetLKey('SecFor') + ' ' + StringToDotString(IntToStr(AnalysedCount)) + ' ' +
      GetLKey('EstimateTime') + ' ? ' + GetLKey('AllFiles');

end;

procedure TTestRegistryForm.FormActivate(Sender: TObject);
begin
  HideWait;
  Label1.Color := $00313131;
  Label1.Caption := GetLKey('TTestRegistryForm.Label1.Caption');
  MainForm.AdjustLabels(Image18, Label2, Label16, nil, nil, nil);
end;

procedure TTestRegistryForm.DrawMap(Map: string);
var
  i: integer;
begin
  ItemPosition := ItemPosition + 1;
  if ItemPosition > 3 then ItemPosition := 0;

  for i := 1 to length(Map) do
  begin
    if Map[i] = ' ' then DrawIndicatior(i - 1, 3)
    else
      if Map[i] = '1' then DrawIndicatior(i - 1, 1)
      else
        if Map[i] = '2' then DrawIndicatior(i - 1, 2)
        else
          if Map[i] = '0' then DrawIndicatior(i - 1, 1)
          else
            if Map[i] = '?' then
            begin

              DrawIndicatior(i - 1, 4 + ItemPosition);

            end;
  end;

end;

procedure TTestRegistryForm.Label2Click(Sender: TObject);
begin
  if AnaliseInProcess then
  begin
    ShowWait(GetLKey('StopProcessCaption'), GetLKey('StopProcessMessage'));
    BreakOperation := True;
    Label1.Color := clMaroon;
    Label1.Caption := GetLKey('STOPAnalise');
    Label1.Refresh;
  end
  else
    Close;
end;

procedure TTestRegistryForm.Label2MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

procedure TTestRegistryForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if AnaliseInProcess then
  begin
    ShowWait(GetLKey('StopProcessCaption'), GetLKey('StopProcessMessage'));
    BreakOperation := True;
    Label1.Color := clMaroon;
    Label1.Caption := GetLKey('STOPAnalise');
    Label1.Color := $00313131;
    Label1.Caption := GetLKey('TTestRegistryForm.Label1.Caption');
    Action := caNone;
  end
 else
  Action := caHide;

end;

procedure TTestRegistryForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_ESCAPE then Label2Click(Sender);
end;

procedure TTestRegistryForm.Panel9MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Label16.Font.Style := Label16.Font.Style - [fsUnderline];
end;

procedure TTestRegistryForm.Label16Click(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar(ProductHomePage), nil, nil, SW_NORMAL);
end;

procedure TTestRegistryForm.PutLabelInfo;
begin
  Label23.Caption := StringToDotString(IntToStr(AllSize)) + ' ' + GetLKey('BytesAt') + ' ' + StringToDotString(IntToStr(HivePath.Count)) + ' ' + GetLKey('Files');
  Label24.Caption := StringToDotString(IntToStr(AnalysedSize)) + ' ' + GetLKey('BytesAt') + ' ' + StringToDotString(IntToStr(AnalysedCount)) + ' ' + GetLKey('FilesBefor');
  Label25.Caption := StringToDotString(IntToStr(AnalysedNewSize)) + ' ' + GetLKey('BytesAt') + ' ' + StringToDotString(IntToStr(AnalysedCount)) + ' ' + GetLKey('FilesAfter');

  if AnalyseEstimateTime <> 0 then
    Label27.Caption := GetLKey('AnalyseTime') + ' ' + StringToDotString(IntToStr(AnalyseTime)) + ' ' +
      GetLKey('SecFor') + ' ' + StringToDotString(IntToStr(AnalysedCount)) + ' ' +
      GetLKey('EstimateTime') + ' ' + StringToDotString(IntToStr(AnalyseEstimateTime)) + ' ' + GetLKey('AllFiles')
  else
    Label27.Caption := GetLKey('AnalyseTime') + ' ' + StringToDotString(IntToStr(AnalyseTime)) + ' ' +
      GetLKey('SecFor') + ' ' + StringToDotString(IntToStr(AnalysedCount)) + ' ' +
      GetLKey('EstimateTime') + ' ? ' + GetLKey('AllFiles');

  Label26.Caption := IntToStr(AnalysePercent) + '% ' + GetLKey('IsNotFragment');

  Label17.Caption := GetLKey('CurName') + ' ' + CurName;
  Label19.Caption := GetLKey('CurSize') + ' ' + StringToDotString(IntToStr(CurSize)) + ' ' + ' byte';
  Label20.Caption := GetLKey('CutTime') + ' ' + StringToDotString(IntToStr(CurTime div 1000)) + ' ' + ' sec';
end;

procedure TTestRegistryForm.FormCreate(Sender: TObject);
begin
  Image9.Parent.DoubleBuffered := true;
end;

procedure TTestRegistryForm.ShowWait(WCaption, WMessage: string);
begin
  Panel10.Left := Self.Width div 2 - Panel10.Width div 2;
  Panel10.Top := Self.Height div 2 - Panel10.Height div 2;
  Label5.Caption := WCaption;
  Label6.Caption := WMessage;
  Panel10.Visible := True;
  Panel10.Repaint;
  Application.ProcessMessages;
end;

procedure TTestRegistryForm.HideWait;
begin
  Panel10.Visible := False;
end;

end.

