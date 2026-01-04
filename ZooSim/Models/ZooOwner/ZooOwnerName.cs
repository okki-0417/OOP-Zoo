namespace ZooSim.Models.ZooOwner;

public class ZooOwnerName
{
  const int NAME_MAX_LENGTH = 255;
  public string Name { get; }

  public ZooOwnerName(string name)
  {
    if (string.IsNullOrEmpty(name)) throw new ArgumentException("オーナーの名前は空にできません。", nameof(name));
    if (name.Length > NAME_MAX_LENGTH) throw new ArgumentException("オーナーの名前は空にできません。", nameof(name));

    Name = name;
  }
}
