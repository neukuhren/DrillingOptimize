unit GraphPlotUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, CuttingModel;

type
  TGraphPlotter = class
  private
    FMargin: Integer;
    function WorldToScreen(CX, CY, W, H: Integer; X1, X2, XMin, XMax, YMin, YMax: Double): TPoint;
    procedure ComputeBounds(const Lines: array of TConstraintLine;
      const Vertices: array of TPoint2; out XMin, XMax, YMin, YMax: Double);
  public
    procedure Draw(Canvas: TCanvas; Rect: TRect;
      const Lines: array of TConstraintLine;
      const Vertices: array of TPoint2;
      const OptX1, OptX2: Double; HasOpt: Boolean);
  end;

implementation

function TGraphPlotter.WorldToScreen(CX, CY, W, H: Integer; X1, X2, XMin, XMax, YMin, YMax: Double): TPoint;
var
  SX, SY: Double;
begin
  if XMax <= XMin then XMax := XMin + 1;
  if YMax <= YMin then YMax := YMin + 1;
  SX := FMargin + (X1 - XMin) / (XMax - XMin) * (W - 2 * FMargin);
  SY := H - FMargin - (X2 - YMin) / (YMax - YMin) * (H - 2 * FMargin);
  Result := Point(CX + Round(SX), CY + Round(SY));
end;

procedure TGraphPlotter.ComputeBounds(const Lines: array of TConstraintLine;
  const Vertices: array of TPoint2; out XMin, XMax, YMin, YMax: Double);
var
  I: Integer;
  First: Boolean;
begin
  First := True;
  for I := Low(Vertices) to High(Vertices) do
  begin
    if First then
    begin
      XMin := Vertices[I].X1;
      XMax := Vertices[I].X1;
      YMin := Vertices[I].X2;
      YMax := Vertices[I].X2;
      First := False;
    end
    else
    begin
      if Vertices[I].X1 < XMin then XMin := Vertices[I].X1;
      if Vertices[I].X1 > XMax then XMax := Vertices[I].X1;
      if Vertices[I].X2 < YMin then YMin := Vertices[I].X2;
      if Vertices[I].X2 > YMax then YMax := Vertices[I].X2;
    end;
  end;
  if First then
  begin
    XMin := 4;
    XMax := 8;
    YMin := -2;
    YMax := 2;
  end;
  XMin := XMin - 0.3;
  XMax := XMax + 0.3;
  YMin := YMin - 0.3;
  YMax := YMax + 0.3;
  if Lines[0].LineNo > 0 then
    ; // suppress hint
end;

procedure TGraphPlotter.Draw(Canvas: TCanvas; Rect: TRect;
  const Lines: array of TConstraintLine;
  const Vertices: array of TPoint2;
  const OptX1, OptX2: Double; HasOpt: Boolean);
var
  W, H, I, J: Integer;
  XMin, XMax, YMin, YMax: Double;
  P1, P2, PO: TPoint;
  A1, A2, B, Xa, Xb: Double;
  Poly: array of TPoint;
  Cx, Cy: Integer;
begin
  FMargin := 36;
  W := Rect.Width;
  H := Rect.Height;
  Cx := Rect.Left;
  Cy := Rect.Top;
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Rect);
  ComputeBounds(Lines, Vertices, XMin, XMax, YMin, YMax);

  Canvas.Pen.Color := clBlack;
  Canvas.Font.Size := 8;
  Canvas.TextOut(Cx + W div 2 - 20, Cy + H - FMargin + 8, 'x2');
  Canvas.TextOut(Cx + 4, Cy + FMargin - 20, 'x1');

  { оси }
  P1 := WorldToScreen(Cx, Cy, W, H, XMin, YMin, XMin, XMax, YMin, YMax);
  P2 := WorldToScreen(Cx, Cy, W, H, XMin, YMax, XMin, XMax, YMin, YMax);
  Canvas.Pen.Color := clGray;
  Canvas.MoveTo(P1.X, P1.Y);
  Canvas.LineTo(P2.X, P2.Y);
  P1 := WorldToScreen(Cx, Cy, W, H, XMin, YMin, XMin, XMax, YMin, YMax);
  P2 := WorldToScreen(Cx, Cy, W, H, XMax, YMin, XMin, XMax, YMin, YMax);
  Canvas.MoveTo(P1.X, P1.Y);
  Canvas.LineTo(P2.X, P2.Y);

  { многоугольник ОДР по вершинам }
  if Length(Vertices) >= 3 then
  begin
    SetLength(Poly, Length(Vertices));
    for I := 0 to High(Vertices) do
      Poly[I] := WorldToScreen(Cx, Cy, W, H, Vertices[I].X1, Vertices[I].X2,
        XMin, XMax, YMin, YMax);
    { простая сортировка по углу для заливки }
    for I := 0 to High(Poly) do
      for J := I + 1 to High(Poly) do
        if ArcTan2(Poly[J].Y - Poly[0].Y, Poly[J].X - Poly[0].X) <
           ArcTan2(Poly[I].Y - Poly[0].Y, Poly[I].X - Poly[0].X) then
        begin
          P1 := Poly[I];
          Poly[I] := Poly[J];
          Poly[J] := P1;
        end;
    Canvas.Brush.Color := $00E0E0FF;
    Canvas.Pen.Color := $008080FF;
    Canvas.Polygon(Poly);
  end;

  { прямые ограничений }
  for I := Low(Lines) to High(Lines) do
  begin
    A1 := Lines[I].A1;
    A2 := Lines[I].A2;
    B := Lines[I].B;
    Canvas.Pen.Color := TColor($000000 + ((I * 37) mod 128) shl 16 + ((I * 19) mod 128) shl 8));
    Canvas.Pen.Width := 1;
    if Abs(A2) > 1e-9 then
    begin
      Xa := XMin;
      Xb := (B - A1 * Xa) / A2;
      P1 := WorldToScreen(Cx, Cy, W, H, Xa, Xb, XMin, XMax, YMin, YMax);
      Xa := XMax;
      Xb := (B - A1 * Xa) / A2;
      P2 := WorldToScreen(Cx, Cy, W, H, Xa, Xb, XMin, XMax, YMin, YMax);
    end
    else if Abs(A1) > 1e-9 then
    begin
      Xa := B / A1;
      P1 := WorldToScreen(Cx, Cy, W, H, Xa, YMin, XMin, XMax, YMin, YMax);
      P2 := WorldToScreen(Cx, Cy, W, H, Xa, YMax, XMin, XMax, YMin, YMax);
    end
    else
      Continue;
    Canvas.MoveTo(P1.X, P1.Y);
    Canvas.LineTo(P2.X, P2.Y);
    Canvas.TextOut(P2.X + 2, P2.Y, IntToStr(Lines[I].LineNo));
  end;

  if HasOpt then
  begin
    PO := WorldToScreen(Cx, Cy, W, H, OptX1, OptX2, XMin, XMax, YMin, YMax);
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Width := 2;
    Canvas.Brush.Color := clRed;
    Canvas.Ellipse(PO.X - 4, PO.Y - 4, PO.X + 4, PO.Y + 4);
    Canvas.TextOut(PO.X + 6, PO.Y - 6, 'opt');
  end;
end;

end.
