using Godot;

public partial class CSharpPlayer : CharacterBody2D
{
    private enum State { Idle, Move, Attack }

    [Export] public float Speed { get; set; } = 200.0f;
    [Export] public float Acceleration { get; set; } = 1500.0f;
    [Export] public float Friction { get; set; } = 1200.0f;
    [Export] public float AttackDuration { get; set; } = 0.3f;

    private State _currentState = State.Idle;
    private float _attackTimer;

    private HealthComponent _healthComponent;
    private HitboxComponent _hitbox;
    private Node2D _attackPivot;
    private ColorRect _sprite;

    public override void _Ready()
    {
        AddToGroup("player");
        _healthComponent = GetNode<HealthComponent>("HealthComponent");
        _hitbox = GetNode<HitboxComponent>("AttackPivot/HitboxComponent");
        _attackPivot = GetNode<Node2D>("AttackPivot");
        _sprite = GetNode<ColorRect>("Sprite");

        _hitbox.Monitoring = false;
    }

    public override void _PhysicsProcess(double delta)
    {
        float dt = (float)delta;
        switch (_currentState)
        {
            case State.Idle:
                StateIdle(dt);
                break;
            case State.Move:
                StateMove(dt);
                break;
            case State.Attack:
                StateAttack(dt);
                break;
        }
        MoveAndSlide();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event.IsActionPressed("attack") && _currentState != State.Attack)
            EnterAttack();
    }

    private void StateIdle(float delta)
    {
        Velocity = Velocity.MoveToward(Vector2.Zero, Friction * delta);
        var inputDir = Input.GetVector("move_left", "move_right", "move_up", "move_down");
        if (inputDir != Vector2.Zero)
            _currentState = State.Move;
    }

    private void StateMove(float delta)
    {
        var inputDir = Input.GetVector("move_left", "move_right", "move_up", "move_down");
        if (inputDir == Vector2.Zero)
        {
            _currentState = State.Idle;
            return;
        }
        Velocity = Velocity.MoveToward(inputDir * Speed, Acceleration * delta);
        _attackPivot.Rotation = inputDir.Angle();
    }

    private void StateAttack(float delta)
    {
        Velocity = Velocity.MoveToward(Vector2.Zero, Friction * delta);
        _attackTimer -= delta;
        if (_attackTimer <= 0.0f)
        {
            _hitbox.Monitoring = false;
            _currentState = State.Idle;
        }
    }

    private void EnterAttack()
    {
        _currentState = State.Attack;
        _attackTimer = AttackDuration;
        _hitbox.Monitoring = true;
    }
}
