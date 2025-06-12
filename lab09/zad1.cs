using System;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedType(Format.Native)]
public struct ComplexNumber : INullable
{
    private double _x;
    private double _y;
    private bool _null;

    public bool IsNull => _null;

    public static ComplexNumber Null
    {
        get
        {
            ComplexNumber h = new ComplexNumber()
            {
                _null = true
            };
            return h;
        }
    }

    public ComplexNumber(double x, double y)
    {
        _x = x;
        _y = y;
        _null = false;
    }

    public ComplexNumber(bool _)
    {
        this._x = this._y = 0;
        this._null = true;
    }

    public double RealPart
    {
        get => _x;
        set => _x = value;
    }

    public double ImaginaryPart
    {
        get => _y;
        set => _y = value;
    }

    public override string ToString() => _x.ToString() + "+" + _y.ToString() + "i";

    public static ComplexNumber Parse(SqlString s)
    {
        if (s.IsNull || s.Value.Trim() == "")
            return Null;

        string value = s.Value;

        string xstr = value.Substring(0, value.IndexOf('+'));
        string ystr = value.Substring(value.IndexOf('+') + 1,
            value.Length - xstr.Length - 2);
        double xx = double.Parse(xstr);
        double yy = double.Parse(ystr);
        return new ComplexNumber(xx, yy);
    }

    public static ComplexNumber Add(ComplexNumber c1, ComplexNumber c2) => new ComplexNumber(c1._x + c2._x, c1._y + c2._y);

    [SqlMethod(OnNullCall = false)]
    public ComplexNumber Conjugate()
    {
        if (IsNull)
        {
            return Null;
        }

        return new ComplexNumber(_x, -_y);
    }

    [SqlMethod(OnNullCall = false)]
    public SqlDouble Modulus()
    {
        if (IsNull)
        {
            return SqlDouble.Null;
        }

        return Math.Sqrt(Math.Pow(_x, 2) + Math.Pow(_y, 2));
    }
}