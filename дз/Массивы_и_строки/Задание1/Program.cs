using System;

class Program
{
    static void Main()
    {
        int[] A = new int[5];
        double[,] B = new double[3, 4];
        Random rnd = new Random();

        Console.WriteLine("Vvedite 5 chisel dlya massiva A:");
        for (int i = 0; i < 5; i++)
        {
            A[i] = Convert.ToInt32(Console.ReadLine());
        }

        // zapolnyaem B sluchaynymi drobnymi chislami
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                B[i, j] = Math.Round(rnd.NextDouble() * 100, 1);
            }
        }

        Console.Write("Massiv A: ");
        for (int i = 0; i < 5; i++)
        {
            Console.Write(A[i] + " ");
        }
        Console.WriteLine();

        Console.WriteLine("Massiv B:");
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                Console.Write(B[i, j] + "\t");
            }
            Console.WriteLine();
        }

        // ishem max, min, summu i proizvedenie po vsem elementam
        double max = A[0];
        double min = A[0];
        double sum = 0;
        double proizv = 1;

        for (int i = 0; i < 5; i++)
        {
            if (A[i] > max) max = A[i];
            if (A[i] < min) min = A[i];
            sum = sum + A[i];
            proizv = proizv * A[i];
        }

        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                if (B[i, j] > max) max = B[i, j];
                if (B[i, j] < min) min = B[i, j];
                sum = sum + B[i, j];
                proizv = proizv * B[i, j];
            }
        }

        Console.WriteLine("Max = " + max);
        Console.WriteLine("Min = " + min);
        Console.WriteLine("Summa vseh elementov = " + Math.Round(sum, 2));
        Console.WriteLine("Proizvedenie vseh elementov = " + proizv);

        // summa chetnyh elementov massiva A
        int sumChet = 0;
        for (int i = 0; i < 5; i++)
        {
            if (A[i] % 2 == 0)
            {
                sumChet = sumChet + A[i];
            }
        }
        Console.WriteLine("Summa chetnyh elementov A = " + sumChet);

        // summa nechetnyh stolbcov B (1-y i 3-y stolbec, schitaem s 1)
        double sumStolb = 0;
        for (int i = 0; i < 3; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                if (j % 2 == 0) // j=0 i j=2 eto 1-y i 3-y stolbec
                {
                    sumStolb = sumStolb + B[i, j];
                }
            }
        }
        Console.WriteLine("Summa nechetnyh stolbcov B = " + Math.Round(sumStolb, 2));
    }
}
