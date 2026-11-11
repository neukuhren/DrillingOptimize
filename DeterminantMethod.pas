unit DeterminantMethod;

{ Процедура решения СЛАУ 2x2 методом определителей — по методичке. }

{$mode objfpc}{$H+}

interface

type
  TMatrix2 = array[1..2, 1..2] of Double;
  TVector2 = array[1..2] of Double;

procedure Determinant(const a: TMatrix2; const b: TVector2; out x1, x2: Double;
  out OK: Boolean; out ErrMsg: string);

implementation

procedure Determinant(const a: TMatrix2; const b: TVector2; out x1, x2: Double;
  out OK: Boolean; out ErrMsg: string);
var
  delta, delta_x1, delta_x2: Double;
begin
  delta := a[1, 1] * a[2, 2] - a[1, 2] * a[2, 1];
  delta_x1 := b[1] * a[2, 2] - a[1, 2] * b[2];
  delta_x2 := a[1, 1] * b[2] - b[1] * a[2, 1];
  if Abs(delta) > 1e-12 then
  begin
    x1 := delta_x1 / delta;
    x2 := delta_x2 / delta;
    OK := True;
    ErrMsg := '';
  end
  else
  begin
    OK := False;
    ErrMsg :=
      'Ошибка вычисления определителя. Вероятно система содержит два равнозначных уравнения и не имеет решений.';
  end;
end;

end.
