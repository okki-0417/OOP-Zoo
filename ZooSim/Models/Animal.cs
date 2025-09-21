namespace ZooSim.Models;
public class Animal
{
  const int MaximumNameLength = 255;
  public string Name { get; }

  public Animal(string name)
  {
    Name = name;
    Validate();
  }

  public void Display()
  {
    Console.WriteLine($"この動物の名前は {Name} です。");
  }

  private void Validate()
  {
    if (string.IsNullOrWhiteSpace(Name))
    {
      throw new ArgumentException("名前は空にできません。");
    }

    if (Name.Length > MaximumNameLength)
    {
      throw new ArgumentException($"名前は{MaximumNameLength}文字以内にしてください。");
    }
  }
}
