# Концепції

<details>
  <summary><a href="./concept/Consequence.md#наслідок">
    <code>Наслідок</code>
  </a></summary>
    Це об'єкт синхронізації, що розширює можливості при написанні асинхронного коду.
</details>

<details>
  <summary><a href="./concept/Competitor.md#конкурент">
    <code>Конкурент</code>
  </a></summary>
    Одним із двох видів данних, що можуть міститись у <a href="./concept/Consequence.md#наслідок">наслідку</a> є
    <code>конкурент</code> - рутина-обробник <a href="./concept/Resource.md#наслідок">ресурсу</a>,
    що передається у <code>наслідок</code>.
</details>

<details>
  <summary><a href="./concept/Resource.md#ресурс">
    <code>Ресурс</code>
  </a></summary>
    Одним із двох видів данних, що можуть міститись у <a href="./concept/Consequence.md#наслідок">наслідку</a> є
    <code>ресурс</code> - дані, що передаються у <code>наслідок</code> для подальшої обробки.
</details>

<details>
  <summary><a href="./concept/ResourceArgument.md#ресурс-аргумент">
    Ресурс-<code>аргумент</code>
  </a></summary>
    Це об'єкт, один із двох видів <a href="./concept/Resource.md#ресурс">ресурсів</a>, що передається у
    <a href="./concept/Consequence.md#наслідок">наслідок</a>.
</details>

<details>
  <summary><a href="./concept/ResourceError.md#ресурс-помилка">
    Ресурс-<code>помилка</code>
  </a></summary>
    Це об'єкт, один із двох видів <a href="./concept/Resource.md#ресурс">ресурсів</a>, що передається у
    <a href="./concept/Consequence.md#наслідок">наслідок</a>.
</details>

# Туторіали

<details>
  <summary><a href="./tutorial/ReplacingCallbackByConsequence.md#заміна-callback-функції-на-наслідок">
    Заміна callback функції на <code>наслідок</code>
  </a></summary>
    Як правильно використати <a href="./concept/Consequence.md#наслідок">наслідок</a> у рутинах, що приймають як
    аргумент callback функцію, передавши замість неї об'єкт класу <code>Consequence</code>.
</details>

<details>
  <summary><a href="./tutorial/CompetitorsQue.md#черга-конкурентів">
    Черга конкурентів
  </a></summary>
    Що таке черга <a href="./concept/Competitor.md#конкурент">конкурентів</a> 
    <a href="./concept/Consequence.md#наслідок">наслідку</a> та як правильно користуватись рутинами-конкурентами.
</details>

<details>
  <summary><a href="./tutorial/TwoKindOfResources.md#два-види-ресурсів">
    Два види <code>ресурсів</code>
  </a></summary>
    Які бувають види <a href="./concept/Resource.md#ресурс">ресурсів</a>, що передаються у 
    <a href="./concept/Consequence.md#наслідок">наслідок</a> та як правильно їх обробляти.
</details>

<details>
  <summary><a href="./tutorial/InspectingConsequence.md#інспектування-наслідку">
    Інспектування <code>наслідку</code>
  </a></summary>
  Як правильно перевірити стан <a href="./concept/Consequence.md#наслідок">наслідку</a> та взаємодіяти із його
  вмістом(<a href="./concept/Resource.md#ресурс">ресурсами</a> і <a href="./concept/Competitor.md#конкурент">конкурентами</a>),
  в ході виконання програми.
</details>

<details>
  <summary><a href="./tutorial/GiveKeepDifference.md#різниця-між-give-та-keep-конкурентами">
  Різниця між <code>give</code> та <code>keep</code> конкурентами
  </a></summary>
  Коли використовувати <code>give</code>, а коли <code>keep</code> конкурент.
</details>

<details>
  <summary><a href="./tutorial/SynchronizingConsequence.md#синхронізація-наслідку">
  Синхронізація <code>наслідку</code>
  </a></summary>
  Як виконати синхронізацію <a href="./concept/Consequence.md#наслідок">наслідку</a> в синхронному коді.
</details>

<details>
  <summary><a href="./tutorial/DeasynchronizingConsequence.md#деасинхронізація-наслідку">
  Деасинхронізація <code>наслідку</code>
  </a></summary>
  Як виконати деасинхронізацію <a href="./concept/Consequence.md#наслідок">наслідку</a> в асинхронному коді.
</details>
