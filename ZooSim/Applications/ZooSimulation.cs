using static System.Console;
using ZooSim.Models;
namespace ZooSim.Applications;

public class ZooSimulation
{
  private readonly ZooOwner ZooOwner;
  private readonly Zoo Zoo;

  public ZooSimulation()
  {
    WriteLine("動物シミュレーションへようこそ！");
    WriteLine("動物園のオーナーとして登録します！");

    var ownerName = GetValidOwnerName();
    var zooName = GetValidZooName();
    ZooOwner = new ZooOwner(ownerName, zooName);
    Zoo = ZooOwner.Zoo;
  }

  private string GetValidOwnerName()
  {
    string? ownerName;

    while (true)
    {
      Write("あなたのお名前を教えてください：");
      ownerName = ReadLine();

      if (!string.IsNullOrWhiteSpace(ownerName))
      {
        WriteLine($"{ownerName}さん、これからよろしくお願いします！");
        return ownerName;
      }

      WriteLine("名前は空にできません。");
    }
  }

  private string GetValidZooName()
  {
    string? zooName;

    while (true)
    {
      Write("動物園の名前を教えてください：");
      zooName = ReadLine();

      if (!string.IsNullOrWhiteSpace(zooName))
      {
        return zooName;
      }

      WriteLine("名前は空にできません。");
    }
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
          Zoo.IntroduceNewAnimal();
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
}
