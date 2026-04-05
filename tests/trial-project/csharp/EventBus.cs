using Godot;

public partial class CSharpEventBus : Node
{
    [Signal] public delegate void PlayerDiedEventHandler();
    [Signal] public delegate void HealthChangedEventHandler(int current, int maximum);
    [Signal] public delegate void DamageDealtEventHandler(int amount, Vector2 position);
    [Signal] public delegate void ScoreChangedEventHandler(int newScore);
    [Signal] public delegate void ItemCollectedEventHandler(string itemName);
    [Signal] public delegate void DialogueStartedEventHandler();
    [Signal] public delegate void DialogueEndedEventHandler();
    [Signal] public delegate void GameSavedEventHandler(string slotName);
    [Signal] public delegate void GameLoadedEventHandler(string slotName);
}
