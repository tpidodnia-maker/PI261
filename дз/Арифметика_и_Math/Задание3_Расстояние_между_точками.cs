using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("x1 =");
        double x1 = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("y1 =");
        double y1 = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("x2 =");
        double x2 = Convert.ToDouble(Console.ReadLine());
        Console.WriteLine("y2 =");
        double y2 = Convert.ToDouble(Console.ReadLine());

        double a = x2 - x1;
        double b = y2 - y1;

        double dist = Math.Sqrt(Math.Pow(a, 2) + Math.Pow(b, 2));

        Console.WriteLine("Rasstoyanie = " + Math.Round(dist, 2));
    }
}
