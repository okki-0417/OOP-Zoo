namespace ZooSim.Models.Animal;

public class AnimalName
{
  const int NAME_MAX_LENGTH = 255;
  public string Name { get; }

  public AnimalName(string name)
  {
    if (string.IsNullOrEmpty(name)) throw new ArgumentException("動物の名前は空にできません。", nameof(name));
    if (name.Length > NAME_MAX_LENGTH) throw new ArgumentException("動物の名前は空にできません。", nameof(name));

    Name = name;
  }
}
