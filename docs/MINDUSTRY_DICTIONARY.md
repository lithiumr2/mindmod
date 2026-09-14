# DICCIONARIO ENCICLOPÉDICO DE CLASES Y PROPIEDADES DE MINDUSTRY (V7/V8)

A continuación se detalla la lista exhaustiva de propiedades requeridas para abarcar la totalidad de las mecánicas de Mindustry en formato HJSON. Este compendio está categorizado por la herencia de clases del código fuente del juego.

## 1. Propiedades Universales de Bloques (Block)
Estas propiedades son heredadas por absolutamente todos los tipos de bloques y deben estar disponibles en el constructor base de tu IDE.
 * type: (String) La clase Java subyacente del bloque.
 * name: (String) Nombre interno del bloque.
 * description: (String) Descripción visible en el juego.
 * health: (Int) Puntos de vida del bloque.
 * size: (Int) Tamaño en casillas (1 = 1x1, 2 = 2x2, etc.).
 * requirements: (Array) Lista de ítems y cantidades para construirlo.
 * category: (String) Pestaña del menú (turret, production, distribution, liquid, power, defense, crafting, units, effect, logic).
 * solid: (Boolean) Si las unidades terrestres colisionan con él.
 * destructible: (Boolean) Si puede ser destruido por daño.
 * hasItems: (Boolean) Si el bloque tiene un inventario interno de ítems.
 * hasLiquids: (Boolean) Si el bloque tiene un tanque interno de líquidos.
 * hasPower: (Boolean) Si el bloque interactúa con la red eléctrica.
 * consumesPower: (Boolean) Si drena energía pasivamente.
 * outputsPower: (Boolean) Si inyecta energía a la red.
 * itemCapacity: (Int) Capacidad máxima de ítems almacenados.
 * liquidCapacity: (Float) Capacidad máxima de líquidos almacenados.
 * alwaysUnlocked: (Boolean) Si está disponible desde el inicio sin investigar.
 * buildVisibility: (String) Visibilidad de construcción (shown, hidden, lightingOnly, sandboxOnly).
 * research: (String) Bloque o nodo padre necesario para desbloquearlo en la campaña.
 * envEnabled: (Int) Máscara de bits para entornos donde se puede construir.
 * envDisabled: (Int) Máscara de bits para entornos donde está prohibido.
 * floating: (Boolean) Si se puede colocar sobre líquidos sin bombas o puentes.
 * placeableLiquid: (Boolean) Si requiere ser colocado sobre un líquido específico.

## 2. Extracción y Minería
### Drill (Taladros sobre menas)
 * tier: (Int) Nivel de dureza máxima que puede minar.
 * drillTime: (Float) Tiempo en ticks para extraer un ítem (menor es más rápido).
 * warmupSpeed: (Float) Velocidad a la que alcanza su máxima eficiencia.
 * liquidBoostIntensity: (Float) Multiplicador de velocidad al recibir refrigerante.
 * drawMineItem: (Boolean) Si muestra visualmente el ítem siendo extraído.
 * updateEffect: (String) Partícula emitida periódicamente al funcionar.
 * drillEffect: (String) Partícula emitida al extraer un ítem.
### BeamDrill (Taladros láser/de distancia)
 * tier: (Int) Nivel de dureza que puede minar.
 * drillTime: (Float) Ticks entre extracciones.
 * range: (Int) Distancia en bloques a la que puede alcanzar las menas.
 * sparkColor: (Color hex) Color de las chispas en el punto de contacto.
 * pulse: (Boolean) Si el láser pulsa visualmente.
 * consumeTime: (Float) Tiempo que tarda en consumir refrigerante si está configurado.
### Pump y SolidPump (Bombas de líquidos)
 * pumpAmount: (Float) Cantidad de líquido extraído por tick.
 * result: (String) En SolidPump, el líquido específico que produce sin importar el suelo.
### Fracker (Fracturadores)
 * pumpAmount: (Float) Cantidad de líquido producido de suelos sólidos.
 * itemUseTime: (Float) Tiempo que dura un ítem consumido antes de pedir otro.

## 3. Logística de Ítems
### Conveyor, ArmoredConveyor, PlastaniumConveyor (Cintas)
 * speed: (Float) Velocidad interna de movimiento (0.01 a 0.2 aprox).
 * displayedSpeed: (Float) Velocidad mostrada en la interfaz del juego (ítems/segundo).
 * junctionReplacement: (String) Bloque que se coloca automáticamente si dos cintas se cruzan.
### Router, Junction, Sorter, LogicSorter (Enrutadores)
 * speed: (Float) Tiempo de retraso interno.
 * invert: (Boolean) Para Sorter, si la lógica de filtrado se invierte de fábrica.
### ItemBridge (Puentes)
 * range: (Int) Distancia máxima en casillas (radio real).
 * transportTime: (Float) Ticks que tarda un ítem en cruzar el puente.
 * pulse: (Boolean) Si emite un efecto visual al transferir.
### MassDriver (Cañones de masa)
 * range: (Float) Distancia máxima de disparo en píxeles (bloques * 8).
 * reload: (Float) Tiempo de recarga entre disparos.
 * itemCapacity: (Int) Capacidad de munición/ítems por paquete disparado.
 * knockback: (Float) Retroceso aplicado al disparar.
 * bulletSpeed: (Float) Velocidad en el aire del paquete disparado.

## 4. Logística de Líquidos
### Conduit, ArmoredConduit (Tuberías)
 * liquidCapacity: (Float) Capacidad en la tubería.
 * liquidPressure: (Float) Presión de empuje hacia el siguiente bloque.
 * leaks: (Boolean) Si el líquido se derrama al romper la tubería.
### LiquidBridge, LiquidRouter, LiquidJunction
 * range: (Int) Para puentes, alcance máximo.

## 5. Producción y Manufactura
### GenericCrafter (Fábricas genéricas)
 * craftTime: (Float) Ticks necesarios para un ciclo de producción.
 * outputItem: (Object o String) Ítem y cantidad producida ({"item": "copper", "amount": 2}).
 * outputItems: (Array) Múltiples salidas de ítems.
 * outputLiquid: (Object o String) Líquido y cantidad producida ({"liquid": "water", "amount": 10}).
 * outputLiquids: (Array) Múltiples salidas de líquidos.
 * craftEffect: (String) Partícula al terminar un ciclo.
 * updateEffect: (String) Partícula mientras produce.
 * drawer: (Object) Objeto avanzado para renders (DrawMulti, DrawSmelt, DrawLiquid, DrawFlame).
### HeatCrafter (Fábricas que requieren calor)
 * heatRequirement: (Float) Temperatura base necesaria para operar.
 * maxEfficiency: (Float) Multiplicador de velocidad máximo según el calor excedente.
### Separator y Incinerator
 * results: (Array) Lista de ítems con sus probabilidades ([{"item": "copper", "amount": 1}]).
 * flameColor: (Color hex) Para incineradores, el color de la llama.

## 6. Sistema de Energía
### PowerNode, BeamNode (Nodos eléctricos)
 * maxNodes: (Int) Conexiones simultáneas permitidas.
 * laserRange: (Float) Distancia máxima para conectar nodos.
 * laserColor1, laserColor2: (Color hex) Colores del rayo eléctrico.
### Battery (Baterías)
 * emptyPower: (Float) Pérdida pasiva (rara vez usada en baterías base, pero disponible).
 * emptyLightColor: (Color hex) Color al estar descargada.
 * fullLightColor: (Color hex) Color al estar cargada al máximo.
### ThermalGenerator, SolarGenerator, ConsumeGenerator (Generadores básicos)
 * powerProduction: (Float) Energía generada por tick.
 * itemDuration: (Float) Tiempo que tarda en quemar un ítem de combustible (ConsumeGenerator).
 * generateEffect: (String) Efecto visual al producir.
### NuclearReactor, ImpactReactor (Reactores complejos)
 * heating: (Float) Velocidad a la que aumenta la temperatura interna.
 * smokeThreshold: (Float) Porcentaje de temperatura donde comienza a emitir humo.
 * flashThreshold: (Float) Porcentaje de temperatura de peligro.
 * explosionRadius: (Int) Radio de destrucción si estalla.
 * explosionDamage: (Float) Daño al estallar.
 * itemDuration: (Float) Consumo del material radiactivo.
 * warmupSpeed: (Float) Velocidad de inicio del Impact Reactor.

## 7. Defensa y Escudos
### Wall (Muros)
 * chanceDeflect: (Float) Probabilidad (0-1) de rebotar balas.
 * flashHit: (Boolean) Si brilla en blanco al recibir impacto.
 * insulated: (Boolean) Si evita que los arcos eléctricos lo atraviesen.
 * absorbLasers: (Boolean) Si detiene balas láser penetrantes.
 * lightningChance: (Float) Probabilidad de emitir rayos al ser golpeado.
 * lightningDamage: (Float) Daño de los rayos defensivos.
### ForceProjector (Escudos)
 * radius: (Float) Radio en píxeles del escudo.
 * shieldHealth: (Float) Vida máxima de la cúpula.
 * cooldownNormal: (Float) Recuperación de escudo pasiva.
 * cooldownLiquid: (Float) Recuperación extra al recibir líquido.
 * phaseRadiusBoost: (Float) Radio extra al recibir tejido de fase.
 * phaseShieldBoost: (Float) Vida extra al recibir tejido de fase.
### OverdriveProjector, OverdriveDome (Aceleradores)
 * range: (Float) Radio de efecto en píxeles.
 * speedBoost: (Float) Multiplicador de velocidad base (ej: 1.5).
 * speedBoostPhase: (Float) Multiplicador extra con recursos avanzados.
 * useTime: (Float) Ticks que dura una unidad de combustible.
### Mender (Sanadores)
 * range: (Float) Radio en píxeles.
 * reload: (Float) Ticks entre curaciones.
 * healPercent: (Float) Porcentaje de vida máxima restaurado por pulso.
 * healAmount: (Float) Vida estática restaurada por pulso.

## 8. Armamento (Torretas)
(Todas las torretas comparten un bloque interno shoot para ráfagas en v7/v8).
### ItemTurret (Torretas balísticas)
 * range: (Float) Alcance en píxeles.
 * reload: (Float) Ticks entre disparos.
 * inaccuracy: (Float) Grados de dispersión del cañón.
 * recoil: (Float) Distancia visual de retroceso del sprite.
 * restitution: (Float) Velocidad a la que el cañón vuelve a su posición.
 * targetAir: (Boolean) Si puede apuntar a unidades aéreas.
 * targetGround: (Boolean) Si puede apuntar a unidades terrestres.
 * shootSound: (String) Nombre del archivo de sonido (ej: "shootBig").
 * ammoTypes: (Object) Mapa donde la llave es el ítem y el valor es la definición de la bala ({"copper": {"type": "BasicBulletType", "damage": 9, "speed": 2.5}}).
### LiquidTurret (Lanzallamas, Tsunamis)
 * extinguish: (Boolean) Si sus balas apagan el fuego.
 * ammoTypes: (Object) Mapa donde la llave es el líquido y el valor es un LiquidBulletType.
### PowerTurret, ContinuousTurret, PointDefenseTurret (Láseres y arcos)
 * shootType: (Object) Definición directa de la bala (no usa ítems), como LaserBulletType o ContinuousLaserBulletType.
 * chargeTime: (Float) Tiempo que tarda en disparar tras fijar blanco.
 * chargeEffects: (Int) Cantidad de chispas en la carga.
 * bulletDamage: (Float) Para el láser continuo, daño continuo por tick.

## 9. Unidades y Ensamblaje
### UnitFactory (Fábricas de unidades base)
 * plans: (Array) Lista de recetas de unidades ([{"unit": "dagger", "time": 600, "requirements": [...]}]).
### Reconstructor (Mejoradores)
 * constructTime: (Float) Tiempo de mejora.
 * upgrades: (Array) Matriz de conversiones ([["dagger", "mace"], ["crawler", "atrax"]]).
### UnitAssembler (Fabricantes modulares)
 * plans: (Array) Unidades T4/T5 construidas por payload.
 * dronesCreated: (Int) Drones auxiliares de construcción.
 * droneType: (String) Tipo de unidad del dron de construcción.

## 10. Bloques Lógicos
### MessageBlock, LogicBlock, MemoryBlock
 * maxInstructionsPerTick: (Int) Velocidad de procesamiento del procesador lógico.
 * range: (Float) Distancia máxima para enlazar variables o bloques.
 * memoryCapacity: (Int) Número máximo de variables numéricas almacenadas.

## 11. Bloques de Almacenamiento y Núcleo
### StorageBlock (Bóvedas, contenedores)
 * itemCapacity: (Int) Cantidad de almacenamiento.
 * coreMerge: (Boolean) Si se adosa físicamente al núcleo para expandirlo.
### CoreBlock (Núcleos principales)
 * unitType: (String) Unidad controlada por el jugador que reaparece (ej: "alpha").
 * unitCapModifier: (Int) Cuántas unidades extra suma al límite global.
 * thrusterLength: (Float) Aspecto visual de los propulsores al viajar.
 * incinerateNonBuildable: (Boolean) Si destruye ítems excedentes.

## Estructuras de Objetos Anidados Vitales (v7/v8)
### El objeto consumes
Para que un bloque drene recursos al funcionar (aplica a fábricas, taladros, reactores, reconstructores), debe usar el formato anidado:
consumes: {
  power: 1.5,
  items: {
    items: [
      copper/1
      lead/2
    ]
  },
  liquids: {
    liquids: [
      water/0.1
    ]
  }
}

### El objeto shoot
Para configurar ráfagas complejas en torretas:
shoot: {
  type: ShootAlternate / ShootPattern / ShootSpread
  shots: 3
  shotDelay: 5
  spread: 4
}


# DICCIONARIO ENCICLOPÉDICO DE PROPIEDADES DE UNIDADES (V7/V8)

## 1. Estadísticas Base y Físicas (UnitType)
 * type: (String) Plantilla base de la unidad (flying, mech, legs, naval, payload, tether, missile).
 * name: (String) Nombre interno del archivo/unidad.
 * description: (String) Descripción visible en el juego.
 * health: (Float) Puntos de vida máximos.
 * armor: (Float) Reducción de daño plana aplicada a cada impacto recibido.
 * hitSize: (Float) Radio de la caja de colisión (hitbox) en píxeles. Una caja muy grande hace que las balas la acierten más fácil.
 * speed: (Float) Velocidad de movimiento máxima.
 * rotateSpeed: (Float) Velocidad de giro en grados por tick.
 * itemCapacity: (Int) Cantidad máxima de ítems que puede cargar simultáneamente.
 * outlineColor: (Color hex) Color del contorno del sprite de la unidad (por defecto suele ser un tono oscuro de su color de equipo).
 * isEnemy: (Boolean) Si aparece como enemigo en el generador de oleadas por defecto.
 * coreUnitDock: (Boolean) Si esta unidad puede acoplarse y controlar el núcleo de la base (como el Alpha, Beta, Gamma).

## 2. Propiedades de Movimiento Específico
### Unidades Voladoras (flying: true)
 * flying: (Boolean) Obligatorio en true para naves. Ignoran terrenos y muros bajos.
 * engineOffset: (Float) Posición Y (hacia atrás) donde se dibuja el propulsor base.
 * engineSize: (Float) Tamaño del rastro del propulsor.
 * lowAltitude: (Boolean) Si la unidad vuela bajo (puede recibir daño de armas antiaéreas y explosiones terrestres como el Impact Reactor al estallar).
 * circleTarget: (Boolean) Si la IA tiende a orbitar el objetivo en lugar de detenerse frente a él (típico en naves Flare/Zenith).
### Unidades Terrestres (Bípedos / mech)
 * mechStepParticles: (Boolean) Si levanta polvo al caminar.
 * mechLegColor: (Color hex) Color de las patas.
 * stepShake: (Float) Cuánto tiembla la cámara con cada paso (para unidades masivas tipo Toxopid).
### Unidades Arácnidas / Hexápodas (legs)
 * legCount: (Int) Cantidad de patas.
 * legLength: (Float) Alcance máximo de cada pata.
 * legSpeed: (Float) Velocidad de animación de la pata.
 * legForwardScl: (Float) Multiplicador de estiramiento hacia adelante.
 * legMoveSpace: (Float) Distancia entre las bases de las patas.
 * hovering: (Boolean) Si flota ligeramente sobre líquidos o abismos cruzando con sus patas.
 * allowLegStep: (Boolean) Si puede pasar por encima de muros sólidos y otras estructuras usando su longitud de pata.
### Unidades Navales (naval)
 * trailLength: (Int) Longitud de la estela de agua dejada al moverse.
 * trailX, trailY: (Float) Posiciones de los emisores de la estela.
 * trailScl: (Float) Ancho de la estela en el agua.
 * waterVision: (Boolean) Si tiene penalización o ventaja de visión en líquidos.

## 3. Minería, Construcción y Carga
 * mineTier: (Int) Dureza máxima del material que la unidad puede minar manualmente.
 * mineSpeed: (Float) Velocidad base a la que extrae recursos.
 * buildSpeed: (Float) Multiplicador de velocidad al construir o reconstruir estructuras.
 * payloadCapacity: (Float) Capacidad de área (tamaño) para levantar bloques o unidades menores (usado por unidades tipo Oct o Quad).

## 4. Inteligencia Artificial (IA) y Apuntado
 * controller: (String) Clase de controlador que dicta su comportamiento (ej: BuilderAI, MinerAI, SuicideAI, DefenderAI).
 * targetAir: (Boolean) Si sus armas intentarán apuntar a enemigos voladores.
 * targetGround: (Boolean) Si sus armas intentarán apuntar a estructuras/unidades terrestres.
 * faceTarget: (Boolean) Si el cuerpo de la unidad debe rotar siempre para mirar a su objetivo (falso si tiene torretas rotativas independientes de 360 grados).

## 5. Configuración de Armas (weapons - Array de Objetos)
Las unidades contienen una lista de objetos arma. Cada arma se monta en el cuerpo de la unidad.
 * name: (String) Nombre del sprite del arma (busca el archivo PNG con este nombre).
 * x, y: (Float) Coordenadas de montaje respecto al centro de la unidad.
 * mirror: (Boolean) Si es true, el motor duplica el arma automáticamente en las coordenadas -x.
 * reload: (Float) Tiempo de recarga del arma en ticks.
 * shootCone: (Float) Margen de grados de tolerancia para disparar antes de estar perfectamente alineado al objetivo.
 * rotate: (Boolean) Si el cañón del arma puede girar independientemente del cuerpo de la unidad.
 * rotateSpeed: (Float) Velocidad de giro de este cañón específico.
 * inaccuracy: (Float) Grados de error al disparar.
 * recoil: (Float) Retroceso visual del cañón al disparar.
 * shootSound: (String) Sonido del disparo.
 * shoot: (Object) Bloque de ráfaga (como en las torretas) con shots, shotDelay y spread.
 * bullet: (Object) Definición del proyectil disparado.

## 6. Configuración de Balas (bullet - Anidado dentro de cada arma)
 * type: (String) El comportamiento principal del proyectil (BasicBulletType, LaserBulletType, MissileBulletType, ArtilleryBulletType, LightningBulletType, PointDefenseBulletType, etc.).
 * damage: (Float) Daño base por impacto directo.
 * speed: (Float) Velocidad de desplazamiento.
 * lifetime: (Float) Tiempo de vida en ticks. (El alcance real es speed * lifetime).
 * pierce: (Boolean) Si atraviesa múltiples enemigos.
 * pierceBuilding: (Boolean) Si atraviesa múltiples estructuras sin detenerse.
 * pierceCap: (Int) Número máximo de elementos que puede atravesar antes de desaparecer.
 * splashDamage: (Float) Daño en área (explosión).
 * splashDamageRadius: (Float) Radio de la explosión en píxeles.
 * status: (String) Efecto de estado aplicado al blanco (ej: burning, freezing, melting, shocked, blasted).
 * statusDuration: (Float) Duración del efecto de estado en ticks.
 * homingPower: (Float) Capacidad de giro de los misiles para perseguir el objetivo (ej: 0.1).
 * homingRange: (Float) Distancia en píxeles a la que el misil detecta un objetivo para perseguirlo.
 * fragBullets: (Int) Cantidad de proyectiles fragmentados que se generan al morir esta bala.
 * fragBullet: (Object) Definición completa (como esta misma lista) de la sub-bala generada por fragmentación.
 * lightning: (Int) Cantidad de rayos eléctricos emitidos al impactar.
 * lightningDamage: (Float) Daño de los rayos secundarios.

## 7. Habilidades Especiales (abilities - Array de Objetos)
Las unidades pueden tener habilidades pasivas o activas anidadas en esta lista.
 * ForceFieldAbility (Escudo deflector pasivo): radius (radio del escudo), regen (recuperación por tick), max (salud total), cooldown (tiempo para reactivarse tras romperse).
 * RepairFieldAbility (Curación en área pasiva): amount (vida curada), reload (tiempo entre pulsos), range (alcance de curación).
 * EnergyFieldAbility (Arcos eléctricos ofensivos automáticos): damage (daño), reload, range, maxTargets (número de enemigos golpeados a la vez).
 * UnitSpawnAbility (Invocación de drones/unidades menores): unit (nombre interno de la unidad a generar), spawnTime (tiempo de gestación), spawnX, spawnY (coordenadas de aparición relativas).
