class PlayerStats {
  double moveSpeed;
  double damage;
  double attackSpeed;     // tiros por segundo → cooldown = 1 / attackSpeed
  double projectileSpeed;
  double critChance;      // 0.0 a 1.0
  double critDamage;      // multiplicador (ex: 1.5 = +50%)
  double pickupRadius;    // raio de atração de itens (XP, vida)
  double maxHp;

  PlayerStats({
    this.moveSpeed = 200,
    this.damage = 15,
    this.attackSpeed = 0.5,
    this.projectileSpeed = 300,
    this.critChance = 0.0,
    this.critDamage = 1.5,
    this.pickupRadius = 60,
    this.maxHp = 20,
  });
}
