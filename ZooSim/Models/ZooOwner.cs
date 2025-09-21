namespace ZooSim.Models;
public class ZooOwner
{
  const int MaximumNameLength = 255;
  private readonly string Name;
  public Zoo Zoo { get; }

  public ZooOwner(string name)
  {
    Name = name;
    Validate();

    Console.WriteLine($"{Name}さん、これからよろしくお願いします！");

    Console.WriteLine($"{Name}さんの最初の動物園を作りましょう！");
    Zoo = CreateZoo();
  }

  static private Zoo CreateZoo()
  {
    string? zooName;

    while (true)
    {
      Console.WriteLine("動物園の名前を入力してください");
      zooName = Console.ReadLine();

      try
      {
        if (string.IsNullOrWhiteSpace(zooName)) throw new ArgumentException("名前は空にできません。");

        Zoo zoo = new(zooName);
        return zoo;
      }
      catch (ArgumentException ex)
      {
        Console.WriteLine($"作成失敗: {ex.Message}");
      }
    }
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
