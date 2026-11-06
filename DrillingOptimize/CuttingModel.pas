unit CuttingModel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, DeterminantMethod;

type
  TIneqKind = (ikLessEqual, ikGreaterEqual);

  TConstraintLine = record
    A1, A2, B: Double;
    Kind: TIneqKind;
    Name: string;
    LineNo: Integer;
  end;

  TCuttingParams = record
    D: Double;
    TTool: Double;
    Cv, q, m, yExp, Kv: Double;
    Nmotor_kW: Double;
    etaMotor: Double;
    nMin, nMax, sMin, sMax: Double;
    Yv, Nv: Double;
    Bv, B2, B3: Double;
    RoughA1, RoughA2, RoughB: Double;
    StiffA1, StiffA2, StiffB: Double;
    StrengthA1, StrengthA2, StrengthB: Double;
    AuxB: Double;
    Ln100: Double;
  end;

  TPoint2 = record
    X1, X2: Double;
    La: Double;
    Valid: Boolean;
    FromLine1, FromLine2: Integer;
  end;

  TOptResult = record
    Found: Boolean;
    X1Opt, X2Opt, LaOpt: Double;
    nOpt, sOpt, VOpt: Double;
    Vertices: array of TPoint2;
    VertexCount: Integer;
  end;

  THandbookCompare = record
    nTab, sTab, VTab: Double;
  end;

procedure DefaultParams(out P: TCuttingParams);
procedure BuildConstraints(const P: TCuttingParams; out Lines: array of TConstraintLine);
function ConstraintCount: Integer;
procedure FillConstraints(const P: TCuttingParams; out Lines: array of TConstraintLine);

function Solve2x2Determinant(const A1, A12, A21, A22, B1, B2: Double;
  out X1, X2: Double): Boolean;

function IsFeasible(const Lines: array of TConstraintLine; const X1, X2: Double): Boolean;
function ObjectiveLa(const X1, X2: Double): Double;

function FindOptimum(const P: TCuttingParams; out R: TOptResult): Boolean;
function DecodeModes(const P: TCuttingParams; X1, X2: Double; out n, s, V: Double): Boolean;
procedure HandbookTabulated(const P: TCuttingParams; out H: THandbookCompare);

implementation

const
  CConstraintCount = 11;

function ConstraintCount: Integer;
begin
  Result := CConstraintCount;
end;

procedure DefaultParams(out P: TCuttingParams);
begin
  P := Default(TCuttingParams);
  P.D := 10;
  P.TTool := 60;
  P.Cv := 23;
  P.q := 0;
  P.m := 0.15;
  P.yExp := 0.45;
  P.Kv := 1.0;
  P.Nmotor_kW := 4.0;
  P.etaMotor := 0.75;
  P.nMin := 200;
  P.nMax := 2000;
  P.sMin := 0.10;
  P.sMax := 0.55;
  { коэффициенты линеаризованных ограничений (как в примере методички для точения) }
  P.Yv := 0.45;
  P.Nv := 0.75;
  P.Bv := 6.2;
  P.B2 := 7.8;
  P.B3 := 6.8;
  P.RoughA1 := 0.5;
  P.RoughA2 := 1.0;
  P.RoughB := 5.5;
  P.StiffA1 := 1.2;
  P.StiffA2 := 0.8;
  P.StiffB := 8.0;
  P.StrengthA1 := 0.9;
  P.StrengthA2 := 1.1;
  P.StrengthB := 7.2;
  P.AuxB := 12;
  P.Ln100 := Ln(100);
end;

procedure RecalcDerivedBounds(var P: TCuttingParams);
var
  Cspeed, rhsSpeed: Double;
begin
  if P.nMin < 1 then P.nMin := 1;
  if P.nMax < P.nMin then P.nMax := P.nMin;
  if P.sMin < 0.001 then P.sMin := 0.001;
  if P.sMax < P.sMin then P.sMax := P.sMin;
  { ограничение по скорости резания (сверление, с.382): n * s^y <= C }
  Cspeed := 1000 * P.Cv * Power(P.D, P.q - 1) * P.Kv / (Pi * Power(P.TTool, P.m));
  if Cspeed <= 0 then
    Cspeed := 1;
  rhsSpeed := Ln(Cspeed) + P.yExp * P.Ln100;
  P.Bv := rhsSpeed;
  P.Yv := P.yExp;
  { упрощённая линеаризация мощности двигателя: x1 + Nv*x2 <= b2 }
  P.B2 := Ln(60000 * P.Nmotor_kW * P.etaMotor / (Pi * P.D)) + P.Nv * P.Ln100;
end;

procedure FillConstraints(const P: TCuttingParams; out Lines: array of TConstraintLine);
var
  PP: TCuttingParams;
begin
  PP := P;
  RecalcDerivedBounds(PP);

  Lines[0].A1 := 1;
  Lines[0].A2 := PP.Yv;
  Lines[0].B := PP.Bv;
  Lines[0].Kind := ikLessEqual;
  Lines[0].Name := 'Скорость / реж. возможности инструмента';
  Lines[0].LineNo := 1;

  Lines[1].A1 := PP.Nv;
  Lines[1].A2 := PP.Yv;
  Lines[1].B := PP.B2;
  Lines[1].Kind := ikLessEqual;
  Lines[1].Name := 'Мощность двигателя';
  Lines[1].LineNo := 2;

  Lines[2].A1 := 1;
  Lines[2].A2 := PP.Yv;
  Lines[2].B := PP.B3;
  Lines[2].Kind := ikLessEqual;
  Lines[2].Name := 'Шероховатость';
  Lines[2].LineNo := 3;

  Lines[3].A1 := PP.StiffA1;
  Lines[3].A2 := PP.StiffA2;
  Lines[3].B := PP.StiffB;
  Lines[3].Kind := ikLessEqual;
  Lines[3].Name := 'Жёсткость станка';
  Lines[3].LineNo := 4;

  Lines[4].A1 := PP.StrengthA1;
  Lines[4].A2 := PP.StrengthA2;
  Lines[4].B := PP.StrengthB;
  Lines[4].Kind := ikLessEqual;
  Lines[4].Name := 'Прочность инструмента';
  Lines[4].LineNo := 5;

  Lines[5].A1 := PP.RoughA1;
  Lines[5].A2 := PP.RoughA2;
  Lines[5].B := PP.RoughB;
  Lines[5].Kind := ikLessEqual;
  Lines[5].Name := 'Качество поверхности';
  Lines[5].LineNo := 6;

  Lines[6].A1 := 1;
  Lines[6].A2 := 0;
  Lines[6].B := Ln(PP.nMax);
  Lines[6].Kind := ikLessEqual;
  Lines[6].Name := 'n <= nmax';
  Lines[6].LineNo := 7;

  Lines[7].A1 := 1;
  Lines[7].A2 := 0;
  Lines[7].B := Ln(PP.nMin);
  Lines[7].Kind := ikGreaterEqual;
  Lines[7].Name := 'n >= nmin';
  Lines[7].LineNo := 8;

  Lines[8].A1 := 0;
  Lines[8].A2 := 1;
  Lines[8].B := Ln(100 * PP.sMax);
  Lines[8].Kind := ikLessEqual;
  Lines[8].Name := 's <= smax';
  Lines[8].LineNo := 9;

  Lines[9].A1 := 0;
  Lines[9].A2 := 1;
  Lines[9].B := Ln(100 * PP.sMin);
  Lines[9].Kind := ikGreaterEqual;
  Lines[9].Name := 's >= smin';
  Lines[9].LineNo := 10;

  Lines[10].A1 := 1;
  Lines[10].A2 := 1;
  Lines[10].B := PP.AuxB;
  Lines[10].Kind := ikLessEqual;
  Lines[10].Name := 'Вспомогательное (резерв)';
  Lines[10].LineNo := 11;
end;

procedure BuildConstraints(const P: TCuttingParams; out Lines: array of TConstraintLine);
begin
  FillConstraints(P, Lines);
end;

function Solve2x2Determinant(const A1, A12, A21, A22, B1, B2: Double;
  out X1, X2: Double): Boolean;
var
  A: TMatrix2;
  B: TVector2;
  Msg: string;
begin
  A[1, 1] := A1;
  A[1, 2] := A12;
  A[2, 1] := A21;
  A[2, 2] := A22;
  B[1] := B1;
  B[2] := B2;
  Determinant(A, B, X1, X2, Result, Msg);
end;

function IsFeasible(const Lines: array of TConstraintLine; const X1, X2: Double): Boolean;
var
  I: Integer;
  L: Double;
begin
  Result := True;
  for I := Low(Lines) to High(Lines) do
  begin
    L := Lines[I].A1 * X1 + Lines[I].A2 * X2;
    case Lines[I].Kind of
      ikLessEqual:
        if L > Lines[I].B + 1e-9 then
          Exit(False);
      ikGreaterEqual:
        if L < Lines[I].B - 1e-9 then
          Exit(False);
    end;
  end;
end;

function ObjectiveLa(const X1, X2: Double): Double;
begin
  Result := X1 + X2;
end;

function FindOptimum(const P: TCuttingParams; out R: TOptResult): Boolean;
var
  Lines: array[0..CConstraintCount - 1] of TConstraintLine;
  I, J, K: Integer;
  X1, X2, La: Double;
  BestLa: Double;
begin
  R := Default(TOptResult);
  FillConstraints(P, Lines);
  SetLength(R.Vertices, 0);
  R.VertexCount := 0;
  BestLa := -Infinity;
  R.Found := False;

  for I := 0 to CConstraintCount - 1 do
    for J := I + 1 to CConstraintCount - 1 do
    begin
      if not Solve2x2Determinant(
        Lines[I].A1, Lines[I].A2,
        Lines[J].A1, Lines[J].A2,
        Lines[I].B, Lines[J].B,
        X1, X2) then
        Continue;
      if not IsFeasible(Lines, X1, X2) then
        Continue;
      La := ObjectiveLa(X1, X2);
      K := Length(R.Vertices);
      SetLength(R.Vertices, K + 1);
      R.Vertices[K].X1 := X1;
      R.Vertices[K].X2 := X2;
      R.Vertices[K].La := La;
      R.Vertices[K].Valid := True;
      R.Vertices[K].FromLine1 := Lines[I].LineNo;
      R.Vertices[K].FromLine2 := Lines[J].LineNo;
      Inc(R.VertexCount);
      if La > BestLa + 1e-12 then
      begin
        BestLa := La;
        R.X1Opt := X1;
        R.X2Opt := X2;
        R.LaOpt := La;
        R.Found := True;
      end;
    end;

  if R.Found then
    DecodeModes(P, R.X1Opt, R.X2Opt, R.nOpt, R.sOpt, R.VOpt);
  Result := R.Found;
end;

function DecodeModes(const P: TCuttingParams; X1, X2: Double; out n, s, V: Double): Boolean;
begin
  n := Exp(X1);
  s := Exp(X2) / 100;
  if (n <= 0) or (s <= 0) or (P.D <= 0) then
    Exit(False);
  V := Pi * P.D * n / 1000;
  Result := True;
end;

procedure HandbookTabulated(const P: TCuttingParams; out H: THandbookCompare);
var
  Cspeed, nEst: Double;
begin
  { ориентир: из формулы скорости при s = sMax/2 }
  Cspeed := 1000 * P.Cv * Power(P.D, P.q - 1) * P.Kv / (Pi * Power(P.TTool, P.m));
  H.sTab := (P.sMin + P.sMax) / 2;
  if H.sTab <= 0 then
    H.sTab := 0.2;
  nEst := Cspeed / Power(H.sTab, P.yExp);
  if nEst < P.nMin then
    nEst := P.nMin;
  if nEst > P.nMax then
    nEst := P.nMax;
  H.nTab := nEst;
  H.VTab := Pi * P.D * H.nTab / 1000;
end;

end.
