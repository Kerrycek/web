<?php

switch ($_POST['entity-type']) {
    case 'fyzicka':
        header('Location: fyzicka-osoba');
        break;
    case 'pravnicka':
        header('Location: pravnicka-osoba');
        break;
    default:
        header('Location: /prihlaska');
}
