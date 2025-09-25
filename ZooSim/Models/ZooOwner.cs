namespace ZooSim.Models;
public class ZooOwner
{
  const int MaximumNameLength = 255;
  public string Name { get; set; }
  public Zoo Zoo { get; set; }

  public ZooOwner(string name, string zooName)
  {
    Name = name;
    Validate();

    Zoo = new(zooName);
  }

  public void IntroduceAnimal() {
    
  }

  public string AddNewZoo(string name)
  {
    try
    {
      Zoo zoo = new(name);
      Zoo = zoo;

      return "";
    }
    catch (ArgumentException ex)
    {
      return ex.Message;
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
