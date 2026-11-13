using System;

class Program
{
    static void Main()
    {
        string text =
            "To be, or not to be, that is the question,\n" +
            "Whether 'tis nobler in the mind to suffer\n" +
            "The slings and arrows of outrageous fortune,\n" +
            "Or to take arms against a sea of troubles,\n" +
            "And by opposing end them? To die: to sleep;\n" +
            "No more; and by a sleep to say we end\n" +
            "The heart-ache and the thousand natural shocks\n" +
            "That flesh is heir to, 'tis a consummation\n" +
            "Devoutly to be wish'd. To die, to sleep";

        string badWord = "die";

        string result = "";
        int count = 0;
        int i = 0;

        while (i < text.Length)
        {
            if (char.IsLetter(text[i]))
            {
                // chitaem celoe slovo
                int start = i;
                while (i < text.Length && char.IsLetter(text[i]))
                {
                    i++;
                }
                string word = text.Substring(start, i - start);

                if (word.ToLower() == badWord)
                {
                    result = result + new string('*', word.Length);
                    count++;
                }
                else
                {
                    result = result + word;
                }
            }
            else
            {
                // znaki prepinaniya, probely, perevod stroki
                result = result + text[i];
                i++;
            }
        }

        Console.WriteLine("Ishodnyy text:");
        Console.WriteLine(text);
        Console.WriteLine();
        Console.WriteLine("Nedopustimoe slovo: " + badWord);
        Console.WriteLine();
        Console.WriteLine("Rezultat:");
        Console.WriteLine(result);
        Console.WriteLine();
        Console.WriteLine("Statistika: " + count + " zameny slova " + badWord + ".");
    }
}
