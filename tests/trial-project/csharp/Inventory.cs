using Godot;
using System.Collections.Generic;

public partial class CSharpInventory : Node
{
    [Signal] public delegate void InventoryChangedEventHandler();
    [Signal] public delegate void ItemAddedEventHandler(Resource item, int quantity);
    [Signal] public delegate void ItemRemovedEventHandler(Resource item, int quantity);

    [Export] public int Capacity { get; set; } = 12;

    private readonly List<InventorySlotData> _slots = new();

    public override void _Ready()
    {
        for (int i = 0; i < Capacity; i++)
            _slots.Add(new InventorySlotData());
    }

    public int AddItem(ItemData item, int quantity = 1)
    {
        int remaining = quantity;

        foreach (var slot in _slots)
        {
            if (remaining <= 0) break;
            if (!slot.IsEmpty && slot.Item == item)
                remaining = slot.AddToStack(remaining);
        }

        foreach (var slot in _slots)
        {
            if (remaining <= 0) break;
            if (slot.IsEmpty)
            {
                slot.Item = item;
                remaining = slot.AddToStack(remaining);
            }
        }

        int added = quantity - remaining;
        if (added > 0)
        {
            EmitSignal(SignalName.ItemAdded, item, added);
            EmitSignal(SignalName.InventoryChanged);
        }

        return remaining;
    }

    public bool HasItem(string itemId)
    {
        foreach (var slot in _slots)
        {
            if (!slot.IsEmpty && slot.Item.Id == itemId)
                return true;
        }
        return false;
    }

    private class InventorySlotData
    {
        public ItemData Item { get; set; }
        public int Quantity { get; set; }
        public bool IsEmpty => Item == null || Quantity <= 0;

        public int AddToStack(int amount)
        {
            if (Item == null) return amount;
            int canAdd = Mathf.Min(amount, Item.MaxStack - Quantity);
            Quantity += canAdd;
            return amount - canAdd;
        }
    }
}
