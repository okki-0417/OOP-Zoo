namespace ZooSim.Models.Zoo;

public class ZooName
{
  const int NAME_MAX_LENGTH = 255;
  public string Value { get; }

  public ZooName(string value)
  {
    if (string.IsNullOrEmpty(value)) throw new ArgumentException("動物の名前は空にできません。", nameof(value));
    if (value.Length > NAME_MAX_LENGTH) throw new ArgumentException("動物の名前は空にできません。", nameof(value));

    Value = value;
  }
}
