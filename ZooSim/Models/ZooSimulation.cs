namespace ZooSim.Models;
public class ZooSimulation
{
  private readonly ZooOwner ZooOwner;
  private AnimalSeller AnimalSeller;

  public ZooSimulation()
  {
    Console.WriteLine("動物シミュレーションへようこそ！");

    AnimalSeller = new AnimalSeller("普通の動物商人");

    Console.WriteLine("動物園のオーナーとして登録します！");
    ZooOwner = CreateZooOwner();
  }

  public void Run()
  {
    while (true)
    {
      Console.WriteLine("\n次の行動を選んでください。");
      Console.WriteLine("1 -> 新しい動物を導入する");
      Console.WriteLine("2 -> ゲームをやめる");

      string? nextAction = Console.ReadLine();

      try
      {
        switch (nextAction)
        {
          case "1":
            ZooOwner.Zoo.IntroduceNewAnimal();
            break;
          case "2":
            Console.WriteLine("さようなら！");
            return;
          default:
            throw new ArgumentException("選択肢のいずれかを入力してください！");
        }
      }
      catch (ArgumentException ex)
      {
        Console.WriteLine($"{ex.Message}");
      }
    }
  }

  static private ZooOwner CreateZooOwner()
  {
    while (true)
    {
      Console.WriteLine("あなたの名前を教えてください。");
      string? zooOwnerName = Console.ReadLine();

      try
      {
        if (string.IsNullOrWhiteSpace(zooOwnerName)) throw new ArgumentException("名前は空にできません。");

        ZooOwner zooOwner = new(zooOwnerName);

        return zooOwner;
      }
      catch (ArgumentException ex)
      {
        Console.WriteLine($"{ex.Message}");
      }

    }
  }
}
