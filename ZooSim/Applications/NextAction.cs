using ZooSim.Models;
using static System.Console;
namespace ZooSim.Applications;

class NextAction
{
  private readonly ZooOwner ZooOwner = CreateZooOwner();
  public delegate void ActionMethod();

  public List<(string description, ActionMethod method)> List() => [
    ("新しい動物を導入する", IntroduceAnimal),
    ("ゲームをやめる", QuitGame),
  ];

  private void IntroduceAnimal()
  {
    WriteLine("動物を導入する機能を実行します。");

    while (true)
    {
      ZooOwner.IntroduceAnimal();
      
    }
  }

  private void QuitGame()
  {
    WriteLine("ゲームを終了します。");
    Environment.Exit(0);
  }

  static private ZooOwner CreateZooOwner()
  {
    string? zooOwnerName;
    while (true)
    {
      WriteLine("あなたの名前を入力してください！");
      zooOwnerName = ReadLine();

      if (!string.IsNullOrWhiteSpace(zooOwnerName))
      {
        string? zooName;

        while (true)
        {
          WriteLine("動物園の名前を入力してください！");
          zooName = ReadLine();

          if (!string.IsNullOrWhiteSpace(zooName))
          {
            return new ZooOwner(zooOwnerName, zooName);
          }
        }
      }
    }
  }

  // private void IntroduceAnimal()
  // {
  //   if (ZooOwner.Zoo == null) return;

  //   IntroduceAnimal introduceAnimal = new(ZooOwner.Zoo);
  //   List<string> introduceWayNames = introduceAnimal.IntroduceWayNames();

  //   for (int i = 0; i < introduceWayNames.Count; i++)
  //   {
  //     WriteLine($"{i} -> {introduceWayNames[i]}");
  //   }

  //   WriteLine("どの方法で動物を導入しますか？");

  //   while (true)
  //   {
  //     string? input = ReadLine();

  //     if (int.TryParse(input, out int index) && index >= 0 && index < introduceWayNames.Count)
  //     {
  //       var actions = introduceAnimal.IntroduceWayAndMethods.Values.ToList();
  //       actions[index].Invoke();
  //       return;
  //     }
  //     else
  //     {
  //       WriteLine("正しい番号を入力してください。");
  //     }
  //   }
  // }
}
