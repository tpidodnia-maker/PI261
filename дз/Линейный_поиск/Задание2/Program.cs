using System;
using System.Diagnostics;

class Program
{
    const int ITERATIONS = 1000;

    static int Find(int[] numbers, int target)
    {
        for (int i = 0; i < numbers.Length; i++)
        {
            if (numbers[i] == target)
            {
                return i;
            }
        }
        return -1;
    }

    // srednee vremya po 1000 zapuskam
    static double Measure(int[] numbers, int target)
    {
        Stopwatch sw = new Stopwatch();
        long sum = 0;

        for (int k = 0; k < ITERATIONS; k++)
        {
            sw.Restart();
            Find(numbers, target);
            sw.Stop();
            sum = sum + sw.ElapsedTicks;
        }

        double avgTicks = (double)sum / ITERATIONS;
        return avgTicks / Stopwatch.Frequency * 1000; // perevodim v millisekundy
    }

    static void Main()
    {
        int[] sizes = { 1000, 10000, 100000, 1000000, 10000000 };
        Random rnd = new Random(123); // odinakovyy massiv pri kazhdom zapuske

        Console.WriteLine("Size\t\tBest\t\tMiddle\t\tWorst");

        foreach (int n in sizes)
        {
            int[] numbers = new int[n];
            for (int i = 0; i < n; i++)
            {
                numbers[i] = rnd.Next();
            }

            int bestTarget = numbers[0];
            int midTarget = numbers[n / 2];
            int worstTarget = -1; // takogo tochno net v massive

            double best = Measure(numbers, bestTarget);
            double middle = Measure(numbers, midTarget);
            double worst = Measure(numbers, worstTarget);

            Console.WriteLine(n + "\t\t" + best.ToString("F4") + "\t\t" + middle.ToString("F4") + "\t\t" + worst.ToString("F4"));
        }
    }
}
