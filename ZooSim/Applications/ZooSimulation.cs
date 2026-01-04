using static System.Console;
using ZooSim.Models.Zoo;
using ZooSim.Models.ZooOwner;

namespace ZooSim.Applications;

public class ZooSimulation
{
  private readonly ZooOwner ZooOwner;

  public ZooSimulation()
  {
    WriteLine("動物シミュレーションへようこそ！");
    WriteLine("動物園のオーナーとして登録します！");

    ZooOwnerName ownerName = GetValidOwnerName();
    ZooName zooName = GetValidZooName();
    ZooOwner = new ZooOwner(ownerName, zooName);
    WriteLine($"{ownerName}さん、これからよろしくお願いします！");
  }

  public void Run()
  {
    while (true)
    {
      WriteLine("次の行動を選んでください。");
      WriteLine("1 -> 動物を導入する");
      WriteLine("2 -> さようなら");

      string? input = ReadLine();

      switch (input)
      {
        case "1":
          // ZooOwner.IntroduceNewAnimal();
          break;
        case "2":
          WriteLine("さようなら！");
          return;
        default:
          WriteLine("選択肢のいずれかを入力してください！");
          break;
      }
    }
  }

  static private ZooOwnerName GetValidOwnerName()
  {
    string? ownerName;

    while (true)
    {
      Write("あなたのお名前を教えてください：");
      ownerName = ReadLine();

      if (!string.IsNullOrWhiteSpace(ownerName)) return new ZooOwnerName(ownerName);

      WriteLine("名前は空にできません。");
    }
  }

  static private ZooName GetValidZooName()
  {
    string? zooName;

    while (true)
    {
      Write("動物園の名前を教えてください：");
      zooName = ReadLine();

      if (!string.IsNullOrWhiteSpace(zooName)) return new ZooName(zooName);

      WriteLine("名前は空にできません。");
    }
  }
}
