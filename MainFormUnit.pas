unit MainFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Math, CuttingModel, GraphPlotUnit, IniFiles;

type

  { TMainForm }

  TMainForm = class(TForm)
    BtnCalc: TButton;
    BtnSaveIni: TButton;
    BtnLoadIni: TButton;
    PaintBoxGraph: TPaintBox;
    MemoLog: TMemo;
    ScrollBoxParams: TScrollBox;
    procedure BtnCalcClick(Sender: TObject);
    procedure BtnLoadIniClick(Sender: TObject);
    procedure BtnSaveIniClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxGraphPaint(Sender: TObject);
  private
    FPlotter: TGraphPlotter;
    FParams: TCuttingParams;
    FResult: TOptResult;
    FLines: array[0..10] of TConstraintLine;
    FHasResult: Boolean;
    FEdits: array of TEdit;
    procedure AddLabeledEdit(AOwner: TWinControl; var LayoutY: Integer;
      const AName, ACaption: string; out E: TEdit);
    procedure BuildParamEdits;
    function EditByName(const AName: string): TEdit;
    procedure ParamsToForm;
    procedure FormToParams;
    procedure UpdateLog;
    function IniPath: string;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FPlotter := TGraphPlotter.Create;
  DefaultParams(FParams);
  FHasResult := False;
  BuildParamEdits;
  ParamsToForm;
  if FileExists(IniPath) then
    BtnLoadIniClick(nil)
  else
    PrepareParams(FParams);
end;

function TMainForm.IniPath: string;
begin
  Result := ExtractFilePath(Application.ExeName) + 'drilling_params.ini';
end;

function TMainForm.EditByName(const AName: string): TEdit;
var
  I: Integer;
begin
  for I := 0 to High(FEdits) do
    if SameText(FEdits[I].Name, AName) then
      Exit(FEdits[I]);
  Result := nil;
end;

procedure TMainForm.AddLabeledEdit(AOwner: TWinControl; var LayoutY: Integer;
  const AName, ACaption: string; out E: TEdit);
var
  L: TLabel;
begin
  L := TLabel.Create(AOwner);
  L.Parent := AOwner;
  L.Left := 8;
  L.Top := LayoutY;
  L.Caption := ACaption;
  E := TEdit.Create(AOwner);
  E.Parent := AOwner;
  E.Name := AName;
  E.Left := 220;
  E.Top := LayoutY - 2;
  E.Width := 100;
  Inc(LayoutY, 26);
end;

procedure TMainForm.BuildParamEdits;
var
  LayoutY, NextTop: Integer;
  E: TEdit;
  G, G2: TGroupBox;
begin
  LayoutY := 8;
  G := TGroupBox.Create(ScrollBoxParams);
  G.Parent := ScrollBoxParams;
  G.Caption := 'Исходные данные (редактируемые)';
  G.Left := 4;
  G.Top := 4;
  G.Width := 360;
  LayoutY := 20;

  SetLength(FEdits, 0);
  AddLabeledEdit(G, LayoutY, 'edD', 'D, мм (номинал)', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edT', 'T, мин (стойкость)', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edCv', 'Cv', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edQ', 'q', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edM', 'm', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edY', 'y (подача)', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edKv', 'Kv', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edNkw', 'N двиг., кВт', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edEta', 'КПД eta', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edNmin', 'n min, об/мин', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edNmax', 'n max, об/мин', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edSmin', 's min, мм/об', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G, LayoutY, 'edSmax', 's max, мм/об', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;

  G.Height := LayoutY + 8;
  NextTop := G.Top + G.Height + 8;

  G2 := TGroupBox.Create(ScrollBoxParams);
  G2.Parent := ScrollBoxParams;
  G2.Caption := 'Коэфф. линеаризованных ограничений (методичка)';
  G2.Left := 4;
  G2.Top := NextTop;
  G2.Width := 360;
  LayoutY := 20;
  AddLabeledEdit(G2, LayoutY, 'edYv', 'Yv', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edNv', 'Nv', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edB3', 'b3 (шерох.)', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edStA1', 'Жёстк. a1', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edStA2', 'Жёстк. a2', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edStB', 'Жёстк. b', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edStrA1', 'Прочн. a1', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edStrA2', 'Прочн. a2', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edStrB', 'Прочн. b', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edRghA1', 'Кач. a1', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edRghA2', 'Кач. a2', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edRghB', 'Кач. b', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  AddLabeledEdit(G2, LayoutY, 'edAuxB', 'Резерв x1+x2<=', E); SetLength(FEdits, Length(FEdits)+1); FEdits[High(FEdits)] := E;
  G2.Height := LayoutY + 8;
  ScrollBoxParams.VertScrollBar.Range := G2.Top + G2.Height + 16;
end;

procedure TMainForm.ParamsToForm;
begin
  EditByName('edD').Text := FloatToStr(FParams.D);
  EditByName('edT').Text := FloatToStr(FParams.TTool);
  EditByName('edCv').Text := FloatToStr(FParams.Cv);
  EditByName('edQ').Text := FloatToStr(FParams.q);
  EditByName('edM').Text := FloatToStr(FParams.m);
  EditByName('edY').Text := FloatToStr(FParams.yExp);
  EditByName('edKv').Text := FloatToStr(FParams.Kv);
  EditByName('edNkw').Text := FloatToStr(FParams.Nmotor_kW);
  EditByName('edEta').Text := FloatToStr(FParams.etaMotor);
  EditByName('edNmin').Text := FloatToStr(FParams.nMin);
  EditByName('edNmax').Text := FloatToStr(FParams.nMax);
  EditByName('edSmin').Text := FloatToStr(FParams.sMin);
  EditByName('edSmax').Text := FloatToStr(FParams.sMax);
  EditByName('edYv').Text := FloatToStr(FParams.Yv);
  EditByName('edNv').Text := FloatToStr(FParams.Nv);
  EditByName('edB3').Text := FloatToStr(FParams.B3);
  EditByName('edStA1').Text := FloatToStr(FParams.StiffA1);
  EditByName('edStA2').Text := FloatToStr(FParams.StiffA2);
  EditByName('edStB').Text := FloatToStr(FParams.StiffB);
  EditByName('edStrA1').Text := FloatToStr(FParams.StrengthA1);
  EditByName('edStrA2').Text := FloatToStr(FParams.StrengthA2);
  EditByName('edStrB').Text := FloatToStr(FParams.StrengthB);
  EditByName('edRghA1').Text := FloatToStr(FParams.RoughA1);
  EditByName('edRghA2').Text := FloatToStr(FParams.RoughA2);
  EditByName('edRghB').Text := FloatToStr(FParams.RoughB);
  EditByName('edAuxB').Text := '12';
end;

procedure TMainForm.FormToParams;
begin
  FParams.D := StrToFloatDef(EditByName('edD').Text, 10);
  FParams.TTool := StrToFloatDef(EditByName('edT').Text, 60);
  FParams.Cv := StrToFloatDef(EditByName('edCv').Text, 23);
  FParams.q := StrToFloatDef(EditByName('edQ').Text, 0);
  FParams.m := StrToFloatDef(EditByName('edM').Text, 0.15);
  FParams.yExp := StrToFloatDef(EditByName('edY').Text, 0.45);
  FParams.Kv := StrToFloatDef(EditByName('edKv').Text, 1);
  FParams.Nmotor_kW := StrToFloatDef(EditByName('edNkw').Text, 4);
  FParams.etaMotor := StrToFloatDef(EditByName('edEta').Text, 0.75);
  FParams.nMin := StrToFloatDef(EditByName('edNmin').Text, 200);
  FParams.nMax := StrToFloatDef(EditByName('edNmax').Text, 2000);
  FParams.sMin := StrToFloatDef(EditByName('edSmin').Text, 0.1);
  FParams.sMax := StrToFloatDef(EditByName('edSmax').Text, 0.55);
  FParams.Yv := StrToFloatDef(EditByName('edYv').Text, 0.45);
  FParams.Nv := StrToFloatDef(EditByName('edNv').Text, 0.75);
  FParams.B3 := StrToFloatDef(EditByName('edB3').Text, 6.8);
  FParams.StiffA1 := StrToFloatDef(EditByName('edStA1').Text, 1.2);
  FParams.StiffA2 := StrToFloatDef(EditByName('edStA2').Text, 0.8);
  FParams.StiffB := StrToFloatDef(EditByName('edStB').Text, 8);
  FParams.StrengthA1 := StrToFloatDef(EditByName('edStrA1').Text, 0.9);
  FParams.StrengthA2 := StrToFloatDef(EditByName('edStrA2').Text, 1.1);
  FParams.StrengthB := StrToFloatDef(EditByName('edStrB').Text, 7.2);
  FParams.RoughA1 := StrToFloatDef(EditByName('edRghA1').Text, 0.5);
  FParams.RoughA2 := StrToFloatDef(EditByName('edRghA2').Text, 1);
  FParams.RoughB := StrToFloatDef(EditByName('edRghB').Text, 5.5);
  FParams.AuxB := StrToFloatDef(EditByName('edAuxB').Text, 12);
  FParams.Ln100 := Ln(100);
end;

procedure TMainForm.UpdateLog;
var
  H: THandbookCompare;
  I: Integer;
begin
  MemoLog.Clear;
  if not FHasResult then
  begin
    MemoLog.Lines.Add('Нажмите «Расчёт».');
    Exit;
  end;
  MemoLog.Lines.Add('=== Оптимум (La = x1 + x2 -> max) ===');
  MemoLog.Lines.Add(Format('x1 = %.5f,  x2 = %.5f,  La = %.5f', [FResult.X1Opt, FResult.X2Opt, FResult.LaOpt]));
  MemoLog.Lines.Add(Format('n = %.2f об/мин,  s = %.4f мм/об,  V = %.4f м/мин',
    [FResult.nOpt, FResult.sOpt, FResult.VOpt]));
  HandbookTabulated(FParams, H);
  MemoLog.Lines.Add('');
  MemoLog.Lines.Add('=== Справочный ориентир (формула v, с.382) ===');
  MemoLog.Lines.Add(Format('n = %.2f,  s = %.4f,  V = %.4f', [H.nTab, H.sTab, H.VTab]));
  MemoLog.Lines.Add('');
  MemoLog.Lines.Add(Format('Вершин ОДР (перебор пар): %d', [FResult.VertexCount]));
  for I := 0 to High(FResult.Vertices) do
    MemoLog.Lines.Add(Format('  L%d x L%d: x1=%.4f x2=%.4f La=%.4f',
      [FResult.Vertices[I].FromLine1, FResult.Vertices[I].FromLine2,
       FResult.Vertices[I].X1, FResult.Vertices[I].X2, FResult.Vertices[I].La]));
end;

procedure TMainForm.BtnCalcClick(Sender: TObject);
begin
  FormToParams;
  PrepareParams(FParams);
  FHasResult := FindOptimum(FParams, FResult);
  FillConstraints(FParams, FLines);
  if not FHasResult then
    ShowMessage('Допустимых вершин не найдено. Проверьте ограничения и коэффициенты.');
  UpdateLog;
  PaintBoxGraph.Invalidate;
end;

procedure TMainForm.PaintBoxGraphPaint(Sender: TObject);
begin
  if not FHasResult then
  begin
    if FResult.VertexCount = 0 then
    begin
      PaintBoxGraph.Canvas.Brush.Color := clBtnFace;
      PaintBoxGraph.Canvas.FillRect(PaintBoxGraph.ClientRect);
      Exit;
    end;
  end;
  FPlotter.Draw(PaintBoxGraph.Canvas, PaintBoxGraph.ClientRect, FLines,
    FResult.Vertices, FResult.X1Opt, FResult.X2Opt, True);
end;

procedure TMainForm.BtnSaveIniClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  FormToParams;
  Ini := TIniFile.Create(IniPath);
  try
    Ini.WriteFloat('Params', 'D', FParams.D);
    Ini.WriteFloat('Params', 'T', FParams.TTool);
    Ini.WriteFloat('Params', 'Cv', FParams.Cv);
    Ini.WriteFloat('Params', 'q', FParams.q);
    Ini.WriteFloat('Params', 'm', FParams.m);
    Ini.WriteFloat('Params', 'y', FParams.yExp);
    Ini.WriteFloat('Params', 'Kv', FParams.Kv);
    Ini.WriteFloat('Params', 'Nkw', FParams.Nmotor_kW);
    Ini.WriteFloat('Params', 'eta', FParams.etaMotor);
    Ini.WriteFloat('Params', 'nMin', FParams.nMin);
    Ini.WriteFloat('Params', 'nMax', FParams.nMax);
    Ini.WriteFloat('Params', 'sMin', FParams.sMin);
    Ini.WriteFloat('Params', 'sMax', FParams.sMax);
    Ini.WriteFloat('Params', 'Yv', FParams.Yv);
    Ini.WriteFloat('Params', 'Nv', FParams.Nv);
    Ini.WriteFloat('Params', 'B3', FParams.B3);
    Ini.WriteFloat('Params', 'StA1', FParams.StiffA1);
    Ini.WriteFloat('Params', 'StA2', FParams.StiffA2);
    Ini.WriteFloat('Params', 'StB', FParams.StiffB);
    Ini.WriteFloat('Params', 'StrA1', FParams.StrengthA1);
    Ini.WriteFloat('Params', 'StrA2', FParams.StrengthA2);
    Ini.WriteFloat('Params', 'StrB', FParams.StrengthB);
    Ini.WriteFloat('Params', 'RghA1', FParams.RoughA1);
    Ini.WriteFloat('Params', 'RghA2', FParams.RoughA2);
    Ini.WriteFloat('Params', 'RghB', FParams.RoughB);
    Ini.WriteFloat('Params', 'AuxB', StrToFloatDef(EditByName('edAuxB').Text, 12));
  finally
    Ini.Free;
  end;
  ShowMessage('Сохранено: ' + IniPath);
end;

procedure TMainForm.BtnLoadIniClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  if not FileExists(IniPath) then
    Exit;
  Ini := TIniFile.Create(IniPath);
  try
    FParams.D := Ini.ReadFloat('Params', 'D', FParams.D);
    FParams.TTool := Ini.ReadFloat('Params', 'T', FParams.TTool);
    FParams.Cv := Ini.ReadFloat('Params', 'Cv', FParams.Cv);
    FParams.q := Ini.ReadFloat('Params', 'q', FParams.q);
    FParams.m := Ini.ReadFloat('Params', 'm', FParams.m);
    FParams.yExp := Ini.ReadFloat('Params', 'y', FParams.yExp);
    FParams.Kv := Ini.ReadFloat('Params', 'Kv', FParams.Kv);
    FParams.Nmotor_kW := Ini.ReadFloat('Params', 'Nkw', FParams.Nmotor_kW);
    FParams.etaMotor := Ini.ReadFloat('Params', 'eta', FParams.etaMotor);
    FParams.nMin := Ini.ReadFloat('Params', 'nMin', FParams.nMin);
    FParams.nMax := Ini.ReadFloat('Params', 'nMax', FParams.nMax);
    FParams.sMin := Ini.ReadFloat('Params', 'sMin', FParams.sMin);
    FParams.sMax := Ini.ReadFloat('Params', 'sMax', FParams.sMax);
    FParams.Yv := Ini.ReadFloat('Params', 'Yv', FParams.Yv);
    FParams.Nv := Ini.ReadFloat('Params', 'Nv', FParams.Nv);
    FParams.B3 := Ini.ReadFloat('Params', 'B3', FParams.B3);
    FParams.StiffA1 := Ini.ReadFloat('Params', 'StA1', FParams.StiffA1);
    FParams.StiffA2 := Ini.ReadFloat('Params', 'StA2', FParams.StiffA2);
    FParams.StiffB := Ini.ReadFloat('Params', 'StB', FParams.StiffB);
    FParams.StrengthA1 := Ini.ReadFloat('Params', 'StrA1', FParams.StrengthA1);
    FParams.StrengthA2 := Ini.ReadFloat('Params', 'StrA2', FParams.StrengthA2);
    FParams.StrengthB := Ini.ReadFloat('Params', 'StrB', FParams.StrengthB);
    FParams.RoughA1 := Ini.ReadFloat('Params', 'RghA1', FParams.RoughA1);
    FParams.RoughA2 := Ini.ReadFloat('Params', 'RghA2', FParams.RoughA2);
    FParams.RoughB := Ini.ReadFloat('Params', 'RghB', FParams.RoughB);
    EditByName('edAuxB').Text := FloatToStr(Ini.ReadFloat('Params', 'AuxB', 12));
  finally
    Ini.Free;
  end;
  ParamsToForm;
end;

end.
