# FP-project Paradigmas de Programación

## Descripción del Proyecto

El objetivo de este proyecto es utilizar Mozart para construir un lenguaje de programación funcional extremadamente básico, que sirva como base para implementar cualquier lenguaje funcional. Este proyecto desarrolla una técnica de reducción de grafos llamada *template instantiation* como enfoque inicial para la programación funcional.

A continuación, se presenta un ejemplo sencillo de un programa en este lenguaje:

```
fun twice x = x + x
twice 5
```

## Autores

Este proyecto fue desarrollado por:

- **Daniel Felipe Vargas Ulloa** - [d.vargasu@uniandes.edu.co](mailto:d.vargasu@uniandes.edu.co)  
- **Diego Fernando Ortiz Ruiz** - [df.ortizr1@uniandes.edu.co](mailto:df.ortizr1@uniandes.edu.co)  
- **Santiago Chamie Rey** - [s.chamie@uniandes.edu.co](mailto:s.chamie@uniandes.edu.co)  

## Casos de Prueba

### Casos Simples

1. **Construcción y reducción básica del árbol de expresiones**  
   **Definición:** `fun square x = x * x`  
   **Llamada:** `square 3`  
   **Resultado esperado:**  
   ```
   9
   ```

2. **Soporte para múltiples parámetros**  
   **Definición:** `fun sum_n x y z n = (x + y + z) * n`  
   **Llamada:** `sum_n 2 2 2 10`  
   **Resultado esperado:**  
   ```
   60
   ```

3. **Uso de varios operadores y orden de operaciones (PEMDAS)**  
   **Definición:** `fun cubeplusone x = x * x * x + 1`  
   **Llamada:** `cubeplusone 3`  
   **Resultado esperado:**  
   ```
   28
   ```

4. **Manejo correcto de paréntesis y orden de operaciones (PEMDAS)**  
   **Definición:** `fun plusonethencube x = x * x * (x + 1)`  
   **Llamada:** `plusonethencube 3`  
   **Resultado esperado:**  
   ```
   36
   ```

### Casos Complejos

1. **Llamados anidados de funciones**  
   Este caso permite evidenciar el correcto funcionamiento de llamadas anidadas de funciones.  
   **Definición:** `fun square x = x * x`  
   **Llamada:** `square square 3`  
   **Resultado esperado:**  
   ```
   81
   ```
2. **Llamados anidados de varias funciones**
   Este caso permite evidenciar el caso mas complejo de funciones anidadas, donde cada parametro de una funcion es una funcion.
   **Definición:** `fun add x y z = x + y + z'
   **Llamada:** `add add 1 1 1 add 1 1 1 add 1 1 1'
   **Resultado esperado:**  
   ```
   9
   ```


3. **Llamados anidados de varias funciones**
   Este caso permite evidenciar el caso mas complejo de funciones anidadas, donde cada parametro de una funcion es una funcion.
   **Definición:** `fun sum_n x y z n = (x + y + z) * n)'
   **Llamada:** `sum_n 1 sum_n 1 1 1 2 3 2'
   **Resultado esperado:**  
   ```
   9
   ```

## Nota

De acuerdo con lo discutido en clase con el profesor Nicolás Cardozo, **no se incluye dentro del alcance del proyecto** la declaración de variables dentro de funciones mediante el uso del keyword `var`. Por ejemplo, definiciones como la siguiente no están soportadas:  

```plaintext
fun var_use x = var y = x + x in var z = y * 2 in z - 3
```

Adicionalmente, si se desae ver la salida completa en mozart, es recomendable aumentar el buffer de salida de la consola de Mozart, ya que la salida de los programas puede ser muy extensa. Para hacer esto, se debe ir a `View -> Console -> Console Buffer Size` y aumentar el tamaño del buffer.

Adicionalmente, se espera que haya un espacio entre cada token en el código fuente. 
