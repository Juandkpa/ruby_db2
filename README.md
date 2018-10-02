# **Ruby on Rails DB**

## **Configuración Postgres (Windows)**

**1.** Verificar instalación de ruby. versión recomendada para windows. [Ruby+Devkit 2.4.4-2](https://rubyinstaller.org/downloads/)

**2.** Instalar [postgresql](https://www.postgresql.org/download/windows/)  tener en cuenta el usuario administrador y el password de ese usuario.

**3.** Instalar gestor de base de datos ([DBeaver](https://dbeaver.io/download/) *recomendado*)

**4.** Hacer la conexión al servidor de db postgres desde el gestor de base de datos.

**5.** En el gestor de db, crear usuario postgres mediante el cual rails se va a conectar a la base de datos.

```sql
CREATE ROLE rails_user WITH createdb login password '****'
```
**rails_user:** reemplazar por el nombre de usuario deseado

**password:** reemplazar por el password deseado.

**6.** En el gestor de db, crear base de datos que se va a usar para el desarrollo del proyecto.

**7.** En el gestor de db, crear la base de datos que vamos a utilizar para nuestro proyecto.

**8.** 
Instalar Rails
```
$ gem install rails
```

**9.** Instalar el driver de postgres para rails
```
$ gem install pg
``` 
**10.** Agregar postgres al path *(Especificamente agregar la ruta donde se encuentra el directorio /bin)*

**11.** Crear nueva aplicación rails con flags para que sea tipo api y use postgres por defecto.
```
$ rails new app --api --database=postgresql
```
**12.** Configurar la conexión a base de datos por parte de rails en el archivo app_name/config/database.yml

```ruby
development:
    <<: *default
    database: db_example #nombre de la base de datos que creamos en el punto 6
    username: rails_user # user que configuramos en el punto 4.
    host: localhost #ip del servidor donde está alojado la db postgres
    port: 5432 #puerto por donde escucha el servidor de base de datos, para postgres el 5432 por defecto.
```

**13.** Ya creada nuestra configuración, con el generador de rails  podemos crear un modelo para mapearlo en nuestra db.
```
$ rails g mdoel user first_name:string last_name:string
```
**14.** Hacemos la migracíón para ver el mapping generado en nuestra base de datos.
```
$ rails db:migrate
```
**15.** Y listo, ya podemos empezar a trabajar con el ORM de rails.
## **Migraciones**

Las migraciones son una manera conveniente, fácil y consistente de modificar el esquema de una base de datos. Estas usan un [DSL](https://www.martinfowler.com/bliki/DomainSpecificLanguage.html) (Lenguaje de dominio especifico, por sus siglas en ingles) de Ruby, de tal manera que no se tenga que utilizar SQL especifico, permitiendo así que los cambios sean independientes del motor de bases de datos.

Cada migración se puede pensar como una nueva versión de la base de datos. Un esquema empieza vacio y cada migración lo modifica para agregar o eliminar tablas, columnas o entradas. ActiveRecord sabe como actualizar el esquema a travez de está linea de tiempo, llevandolo desde cualquier punto en el que se encuentre hasta la última versión. ActiveRecord también actualizará el archivo `db/schema.rb` para que tenga la ultima versión actualizada.

#### **Ejemplo:**
```ruby
class CreatePublications < ActiveRecord::Migration[5.2]
  def change
    create_table :publications do |t|
      t.string :codigo
      t.string :titulo
      t.datetime :fecha
      t.integer :tipo      

      t.timestamps
    end
  end
end
```

### **Creando migraciones**
Las migraciones se guardan en archivos en la carpeta `db/migrate` uno por cada clase migración. El nombre del archivo es de la forma YYYYMMDDHHMMSS_create_publications.rb un timestamp usado por rails para determinar el orden en que correra las migraciones y un nombre que identifica que hace la migración. El nombre de la clase migración debe corresponder a la última parte del archivo en camel case, en este caso CreatePublication.

Para crear migraciones se puden utilizar generadores de la siguiente manera:
```
$ rails generate migration AddStateToCopies
```
generará:
```ruby
class AddStateToCopies < ActiveRecord::Migration[5.0]
  def change
  end
end
``` 
Al generador se le pueden pasar las columnas que se desean agregar, incluso con indices

```
$ rails generate migration AddStateToCopies state:integer:index
```
generará:
```ruby
class AddStateToCopies < ActiveRecord::Migration[5.0]
  def change
    add_column :copies, :state, :integer
    add_index :copies, :state
  end
end
```

De manera similar se puede crear una migración para remover columnas.
```
$rails generate migration RemoveStateFromCopies state:integer
```
generará:
```ruby
class RemoveStateFromCopies < ActiveRecord::Migration[5.0]
  def change
    remove_column :copies,  :state, :integer
  end
end
```
Si la migración es de la forma createXXX y es seguida de una lista de columnas con sus nombres y tipos, entonces la migración creara la tabla XXX con las columnas listadas.
```
$rails generate migration CreatePlaces name:string code:string
```
generará
```ruby
class CreatePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table: products do |t|
      t.string :name
      t.string :part_number
    end
  end
end
```
Todas las clases generadas son un punto de partida, estás se pueden modificar para lograr lo que se desee.

También se pueden agregar asociaciones, por ejemplo `references` sirve para definir un tipo de asociación belongs_to
```
$rails generate migration AddThemeRefToPublications theme:references
```
generará
```ruby
class AddThemeRefToPublications < ActiveRecord::Migration[5.0]
  def change
    add_reference :publications, :theme, foreign_key: true
  end
end
```
Está migración creará una columna theme_id en la tabla publications con el índice.

También se pueden crear generadores que creen jointables si `JoinTable` hace parte del generador que se va a crear así:
```
$ rails g migration CreateJoinTableAuthorPublication
```
generará
```ruby
class CreateJoinTableAuthorPublication < ActiveRecord::Migration[5.0]
  def change
    create_join_table :authors, :publications do |t|
      t.index [:author_id, :publication_id]
    end
  end
end      
```

### **Pasando Modificadores**
Algunos tipos de modificadores conmunmente usados pueden ser pasados directamente en la linea de comando. Estos son encerrados en corchetes de llave y siguen el tipo de campo, así:
```
$ rails generate migration AddDetailsToPlace latitude:decilmal{3,8} longitude:decimal{3,8}
```

```ruby
class AddDetailsToPlace < ActiveRecord::Migration[5.0]
  def change
    add_column :place, :latitude, :decimal, precision: 15, scale: 10
    add_column :place, :longitude, :decimal, precision: 15, scale: 10
  end
end
```

### **Escribiendo migraciones**
Como dijimos anteriormente generar la migración solo es el punto de partida, podemos modificarlas para mapear lo que necesitamos.

1. **Creando una tabla**
   ```ruby
   craete_table :places options:"ENGINE=BLACKHOLE" comment: "Diferentes lugares" do |t|
      t.string :name
      t.decimal :latitude
      t.decimal :longitude
   end
   ```
  Por defecto `create_table` crea una llave primaria llamada `id`, actualmente solo los adaptadores de mysql y postgresql soportan comentarios.

2. **Creando Tabla Join**
   El metodo de migración `create_join_table` crea una HABTM (has and belongs to many) join table, un uso tipico será:
   ```ruby
   create_join_table :authors, :publications
   ```
   La cual creará una tabla authors_publications con 2 columnas `author_id` y `publication_id`, estás columnas tienen la opción `:null` por defecto en `false`. Esto puede ser modificado especificandolo la opción  `:column_options` 
   ```ruby
   create_join_table :authors, :publications, column_options: {null: true}
   ```
   los indices no son creados por defecto, para lo cual se puede pasar un block.
   ```ruby
   create_join_table :authors, :publications do |t|
      t.index :author_id
      t.idex :publication_id
    end
   ```

3. **Cambiando tablas** es usado para cambiar tablas existentes. Es usado de manera similar a create_table paro el objeto yielded al bloque sabe más trucos.
    ```ruby
    change_table :author do |t|
     t.remove :last_name, :first_name
      t.string :born_day
      t.index :born_day
      t.rename :code, :author_code
    end
    ```
4. **Cambiando Columnas** Como `remove_column` y `add_column` Rails tiene el metodo `change_column`
    ```ruby
    change_column :author, :born_day, :datetime
    ```
    El método `change_column` es irreversible

    Otros métodos change_column
    ```ruby
    change_column_null :author, :first_name, false
    change_column_default :copies, :enabled, from: true, to: false #reversible
    change_column_default :copies, :enabled, false #irreversible
    ``` 


5.  **Cuando los helpers no son suficientes**

  ```ruby  
  Product.connection.execute("UPDATE place SET name = 'central' WHERE 1=1")
  ```

6.  **Usando el método change**
   - add_column
   - add_foreign_key
   - add_index
   - add_reference
   - add_timestamps
   - change_column_default  (must supply a :from and :to option)
   - change_column_null
   - create_join_table
   - create_table
   - disable_extension
   - drop_join_table
   - drop_table (must supply a block)
   - enable_extension
   - remove_column (must supply a type)
   - remove_foreign_key (must supply a second table)
   - remove_index
   - remove_reference
   - remove_timestamps
   - rename_column
   - rename_index
   - rename_table

7.  **Usando Reversible** Migraciones complejas pueden requerir procesamiento que ActiveRecord, no sabe como revertir. Para esto se puede usar reversible para especficar que hacer cuando se está corriendo una migración y que cuando se está revirtiendo.

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end
 
    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
          ALTER TABLE distributors
            ADD CONSTRAINT zipchk
              CHECK (char_length(zipcode) = 5) NO INHERIT;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE distributors
            DROP CONSTRAINT zipchk
        SQL
      end
    end
 
    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```
### **Ejecutando migraciones**
  ```
  $ rails db:migrate
  ```
  Ejecutará todos los métodos change o up de todas las migraciones que no hayan sido ejecutadas previamente.
  *Nota:* este comando también ejecutara el comando `db:scheme:dump` que actualiza el archivo `db/schema.rb` para hacerlo coincidir con el esquema de la base de datos actual.

  ```
  $ rails db:migrate VERSION=20080906120100
  ```
  Si la versión 20080906120100 es mayor a la versión actual, el comando ejecutara el método change (o up) sobre todas las migraciones de la versión actual hasta la versíón 20080906120100, incluyendola.
  Si la versión 20080906120100 es menor a la versión actual, el comando ejectura el método down de todas migraciones devolviendose hasta la versión que se le pasa como argumento sin incluirla.

  ### **Rolling Back**
  Se pueden revertir migraciones si necesidad de despecificar el número de versión así.
  ```
  $rails db:rollback
  ```
  Este comando revertira la ultima migración

  Además podemos revertir varias migraciones al mismo tiempo:
  ```
  $rails db:rollback STEP=5
  ```
  Revertira las últimas 5 migraciones.

  Con la opcion redo podemos revertir y volver a correr la migración
  ```  
  $ rails db:migrate:redo STEP=3
  ```

  ### **Incializando la base de datos**

  El comando `$ rails db:setup` creará la base de datos, cargara el esquema y la incializará con los datos semilla.
  ### **Re inicializando la base de datos**
  El comando `$ rails db:reset` eliminará la base de datos y la inicializará de nuevo. Equivalente a `$rails db:drop db:setup`
  ### **Ejecutando una migración especifica**
  Si se quiere ejecutar una migración especifica up or down, el commando `db:migrate:up` and `db:migrate:down` lo hará. Simplemente hay que especificar la versión de la migración que queremos ejecutar.
  ```
  $rails db:migrate:up VERSION=20080906120000
  ```
   En este caso si la migración ya se ejecutó anteriormente, rails no hará nada.  

   Por defecto las migraciones se ejecutan en ambiente de desarrollo, pero también podemos ejecutarlas en otros ambientes, especificando la opcion RAILS_ENV, por ejemplo si se necesita ejecutar las migraciones en un ambiente de prueba test, ejecutariamos.
   ```
   $rails db:migrate RAILS_ENV=test
   ```

  ### **Cambiando Migraciones Existentes**

   Si ya se ha corrido una migración, no es posible editarla simplemente modificando la clase que la generó. Si se cometió un error se podría simplemente usar el comando `rails db:rollback` editar la migracíón y ejecutar nuevamente `rails db:migrate` para guardar los cambios adecuados.
   Sin embargo esto no es buena practica cuando se está trabajando en un equipo de desarrollo, en el que los demas miembros del equipo ya tienen estos cambios. Por esto lo recomendable es hacer una nueva migración en la que se pongan los cambios que se requieren.

   ### **Schema Dumping**
   Las migraciones no son la fuente autorizada del esquema de base de datos. La fuente original reside en el archivo `db/schema.rb` el cual intenta capturar el estado actual del esquema de base de datos.

   Tiene a ser más rápido y menos propenso a errores crear una nueva instancia de la base de datos de la aplicación cargando el archivo de esquema de la base de datos por medio del comando `$ rails db:schema:load` en lugar de repetir toda la historia de migraciones.

   Por defecto el formato de este archivo de esquema es :ruby, pero puede ser modificado para que sea :sql modificando la opción `config.active_record.schema_format` en `config/application.rb`. El formato sql se utiliza generalmente cuando se quiere tener una representación más exacta de la base de datos, esto cuando se han usado funciones especificas del motor de base de datos, que ruby no controla por defecto, como triggers, procedimientos almacenados y otros..

   *Basado en [Active record migrations, Ruby guides](https://edgeguides.rubyonrails.org/active_record_migrations.html)*

## **Asociaciones**.
1. **La asociación belongs_to**
   
    La asociación belongs_to sirve para configurar una relacion uno a uno con otro modelo. De esta manera cada instancia de un modelo pertenece a una instancia de otro.

    ```ruby
      class Publication < ApplicationRecord
        belongs_to :theme
      end
    ```
    ![alt text](public/belongs_to_orange.PNG)

    La asociación belongs_to debe usar el término en singular.

    La migración correspondiente debe verse algo como:
    ```ruby    
    class CreateThemes < ActiveRecord::Migration[5.0]
      def change
        create_table :publications do |t|
          t.string :code
          t.string :title
          t.datetime :date          
          t.belongs_to :theme, index: true

          t.timestamps
        end
    
        create_table :themes do |t|
          t.name :string
          t.integer :theme_type
          t.timestamps
        end
      end
    end
    ```

2. **La asociación has_one**

    La asociación has_one también configura una relación uno a uno con otro modelo, pero con una semantica diferente. Indica que cada instancia de un modelo contiene o procesa una instancia de otro modelo.
    ```ruby
    class User < ApplicationRecord
      has_one :suscription
    end
    ```
    ![has one](public/has_one.PNG)

    La migración correspondiente debe verse algo como:
    ```ruby
    class CreateUsers < ActiveRecord::Migration[5.0]
        def change
          create_table :users do |t|
            t.string :first_name
            t.string :last_name
            t.string :dni
            t.timestamps
          end
      
          create_table :subscriptions do |t|
            t.belongs_to :user, index: {unique:true}, foreign_key: true
            t.string :code
            t.datetime :expiration_date
            t.integer :subs_type
            t.integer :user_id
            t.timestamps
          end
        end
      end
    ```
    Dependiendo del caso, podría ser necesario crear un indice único y/o un foreign key constraint

3. **La asociación has_many.**
    Una asociación has_many indica una relación uno a muchos con otro modelo. Frecuentemente esta asociacion es encontrada en el otro lado de una asociación `belongs_to`. Indica que cada instancia de un modelo tiene cero o mas instancias de otro modelo. En nuestro ejemplo un tema puede tener muchas publicaciones se definiría así:

     ```ruby
     class Theme < ApplicationRecord
        has_many: publications
     end
     ```

     ![has_many](public/has_many.PNG)

    La migración correspondiente podria lucir como:
    ```ruby
    class CreateThemes < ActiveRecord:Migration[5.0]
      def change
        create_table :themes do |t|
          t.string :name
          t.integer :theme_type
        end

        create_table :publications do |t|
          t.belongs_to :theme, index: true
          t.string :code
          t.string :title
          t.date   :date
          t.string :type
        end
      end
    end
    ```
4. **La asociación has_many :through**

    Una relación de este tipo es frecuentemente usada para para establecer una conexión muchos a muchos con otro modelo. Indica que el modelo declarado puede ser relacionado con 0 o mas instancias de otro modelo a través de un tercer modelo. 
    ```ruby
    class Copy < ApplicationRecord
      has_many :loans
      has_many :users, through: loans
    end

    class Loan < ApplicationRecord
      belongs_to :copy
      belongs_to :patient
    end

    class User < ApplicationRecord
      has_many :loans
      has_many :copies, through : loans
    end
    ```
    ![has_many](public/has_many_through.PNG)

    La migración correspoindiente debe verse algo como:

    ```ruby
    class CreateLoans < ActiveRecord::Migration[5.0]
      def change
        create_table :users do |t|
          t.string :first_name
          t.string :last_name
          t.string :last_name
          t.string :dni
          t.timestamps
        end

        create_table :copies do |t|
          t.string :code
          t.integer :place
          t.timestamps
        end

        craete_table :loans do |t|
          t.belongs_to :users, index: true
          t.belongs_to :copies, index: true
          t.datetime :start_date
          t.datetime :end_date     
          t.timestamps 
        end
      end
    end            
    ```
    La asociación has many through también es util para establecer atajos a través de asociaciones has many asociadas. Por ejemplo si un 'theme' tiene muchas 'publications' y una 'publication' tiene muchas 'copies', Puede ser que se quiera tener una colección de todas las 'copies' de un 'theme'.
    Esto se puede configurar de la siguiente manera.

    ```ruby
      class Theme < ApplicationRecord
        has_many :publications
        has_many :copies, through :publications
      end
      
      class Publications < ApplicationRecord
        belongs_to :theme
        has_many :copies
      end

      class Copy < ApplicationRecord
        belongs_to :publication
      end
    ```
    De esta manera rails ahora podrá entender
    ```ruby
      @theme.copies
    ```

5. **Asociación Has_one :through**
    Esta relación establece una relación uno a uno con otro modelo, indicando que el modelo declarado puede relacionarse con una instancia de otro modelo a través de un tercer modelo. Por ejemplo, si cada 'user' tiene una 'subscription' y cada 'subscription' está asociada a una 'subscription_history', entonces el modelo 'user' podría configurarse como:

    ```ruby
    class User < ApplicationRecord
      has_one :subscripton
      has_one :subscription_history, through :subscription
    end

    class Subscription < ApplicationRecord
      belongs_to :user
      has_one :subscription_history
    end

    class SubscriptionHistory < ApplicationRecord
      belongs_to :subscrition
    end

    ```

    ![has_one :through](public/has_one_through.PNG)

    La migración correspoindiente debe verse algo como:

     ```ruby     
        class CreateSubscriptonHistories < ActiveRecord::Migration[5.0]
          def change
            create_table :users do |t|
              t.string :first_name
              t.string :last_name
              t.string :last_name
              t.string :dni
              t.timestamps
            end
        
            create_table subscription do |t|
              t.belongs_to :user, index: true
              t.string :code
              t.datetime :expiration_date
              t.inger :subs_type                            
              t.timestamps
            end
        
            create_table :subscription_histories do |t|
              t.belongs_to :subscription, index: true
              t.integer :canceled_times
              t.timestamps
            end
          end
        end
     ```
6. La asociación has_and_belongs_to_many

    Crea una relación muchos a muchos de manera directa con otro modelo, sin necesidad de un tercer modelo.
    En el caso de aplicación un 'author' puede crear muchas  'publications' y una 'publication' puede ser creada por muchos 'authors', para logarlo se puede declarar así:

    ```ruby
    class Author < ApplicationRecord
      has_and_belongs_to_many :publications
    end

    class Publication < ApplicationRecord
      has_and_belongs_to_many :authors
    end
    ```
    ![has_and_belongs_to_many](public/has_and_belongs_to_many.PNG)

    La migración correspoindiente debe verse algo como:

    ```ruby
    
      class CreateAuthorPublications < ActiveRecord::Migration[5.0]
        def change
          create_table :author do |t|
            t.string :fist_name
            t.string :last_name
            t.string :code
            t.timestamps
          end
      
          create_table :publication do |t|
            t.string :code
            t.string :title
            t.datetime :date
            t.integer :type
            t.timestamps
          end
      
          create_table :author_publications, id: false do |t|
            t.belongs_to :author, index: true
            t.belongs_to :publication, index: true
          end
        end
      end
    ```
  *Basado en [Active record associations, Ruby guides](https://edgeguides.rubyonrails.org/association_basics.html)*