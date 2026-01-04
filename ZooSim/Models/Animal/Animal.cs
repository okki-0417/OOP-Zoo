namespace ZooSim.Models.Animal;

public class Animal(string name)
{
  public AnimalName Name { get; } = new AnimalName(name);

  public bool Equals(Animal? other)
  {
      if (other is null) return false;
      return Name == other.Name;
  }

  public override bool Equals(object? obj) => Equals(obj as Animal);
  public override int GetHashCode() => HashCode.Combine(Name);
  public static bool operator ==(Animal? left, Animal? right) => Equals(left, right);
  public static bool operator !=(Animal? left, Animal? right) => !Equals(left, right);
}
