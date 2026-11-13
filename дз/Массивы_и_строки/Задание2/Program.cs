using System;

class Program
{
    static void Main()
    {
        int[,] arr = new int[5, 5];
        Random rnd = new Random();

        Console.WriteLine("Massiv 5x5:");
        for (int i = 0; i < 5; i++)
        {
            for (int j = 0; j < 5; j++)
            {
                arr[i, j] = rnd.Next(-100, 101);
                Console.Write(arr[i, j] + "\t");
            }
            Console.WriteLine();
        }

        int min = arr[0, 0];
        int max = arr[0, 0];
        int minPos = 0;
        int maxPos = 0;

        for (int i = 0; i < 5; i++)
        {
            for (int j = 0; j < 5; j++)
            {
                int pos = i * 5 + j; // nomer elementa, esli idti po poryadku

                if (arr[i, j] < min)
                {
                    min = arr[i, j];
                    minPos = pos;
                }
                if (arr[i, j] > max)
                {
                    max = arr[i, j];
                    maxPos = pos;
                }
            }
        }

        // min mozhet stoyat posle max, poetomu menyaem mestami
        int start = minPos;
        int end = maxPos;
        if (start > end)
        {
            int temp = start;
            start = end;
            end = temp;
        }

        int summa = 0;
        for (int i = 0; i < 5; i++)
        {
            for (int j = 0; j < 5; j++)
            {
                int pos = i * 5 + j;
                if (pos > start && pos < end)
                {
                    summa = summa + arr[i, j];
                }
            }
        }

        Console.WriteLine("Min = " + min + " (poziciya " + minPos + ")");
        Console.WriteLine("Max = " + max + " (poziciya " + maxPos + ")");
        Console.WriteLine("Summa elementov mezhdu nimi = " + summa);
    }
}
