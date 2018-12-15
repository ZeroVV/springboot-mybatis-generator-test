## Springboot+mybatis 搭配mybatis逆向工程

> 这里是以MySQL为例

1. 首先我们需要创建数据库。（这里我创建的数据库的名称是newtest）并且创建两张表，分别是category和product。以他们为例演示： 
   下面是创建这两张表的代码：

```sql
create table category(
id int(11) primary key auto_increment not null,
name varchar(255) default null)
engine=innodb default charset=utf8;

create table product(
id int(11) primary key auto_increment not null,
name varchar(255)  default null,
price float default null,
cid int(11) default null,0
constraint fk_product_category foreign key (cid) references category(id)
)engine=innodb default charset=utf8;
```

1. 题主这里是以Intellij IDEA为例。先创建springboot工程。 
   然后添加如下所示的依赖（也就是我们的pom.xml文件，你可以直接全部复制我的文件，它是完整的）：（其中的版本号最好和我的一样，你先跑出效果，然后再自己修改）

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
       <modelVersion>4.0.0</modelVersion>
   
       <groupId>com.example</groupId>
       <artifactId>springboot-mybatis-generator-test</artifactId>
       <version>0.0.1-SNAPSHOT</version>
       <packaging>jar</packaging>
   
       <name>springboot-mybatis-generator-test</name>
       <description>Demo project for Spring Boot</description>
   
       <parent>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-parent</artifactId>
           <version>1.5.10.RELEASE</version>
           <relativePath/> <!-- lookup parent from repository -->
       </parent>
   
       <properties>
           <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
           <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
           <java.version>1.8</java.version>
       </properties>
   
       <dependencies>
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-web</artifactId>
           </dependency>
   
           <dependency>
               <groupId>mysql</groupId>
               <artifactId>mysql-connector-java</artifactId>
               <scope>runtime</scope>
           </dependency>
   
           <dependency>
               <groupId>org.springframework.boot</groupId>
               <artifactId>spring-boot-starter-test</artifactId>
               <scope>test</scope>
           </dependency>
   
           <dependency>
               <groupId>org.mybatis.spring.boot</groupId>
               <artifactId>mybatis-spring-boot-starter</artifactId>
               <version>1.1.1</version>
           </dependency>
   
       </dependencies>
   
       <build>
           <plugins>
               <plugin>
                   <groupId>org.springframework.boot</groupId>
                   <artifactId>spring-boot-maven-plugin</artifactId>
               </plugin>
               <plugin>
                   <groupId>org.mybatis.generator</groupId>
                   <artifactId>mybatis-generator-maven-plugin</artifactId>
                   <version>1.3.2</version>
                   <configuration>
                       <verbose>true</verbose>
                       <overwrite>true</overwrite>
                   </configuration>
               </plugin>
           </plugins>
       </build>
   
   
   </project>
   ```

2. 在application.yml文件中配置数据源。（在用IDEA时，IDE默认创建的不是.yml文件，所以需要你删掉，然后建立这个文件。官方也推荐建立.yml文件，我后面给出了源代码，你可以参考一下）。

   ```yaml
   spring:
     datasource:
       driver-class-name: com.mysql.jdbc.Driver
       url: jdbc:mysql://127.0.0.1:3306/newtest
       username: root
       password: admin
   server:
     port: 8081
   ```

3. 在resources文件夹下创建generatorConfig.xml文件。（用于生成逆向工程的文件） 代码如下：

   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE generatorConfiguration
           PUBLIC "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
           "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
   
   <generatorConfiguration>
   
       <properties resource="application.yml" />
       <!-- mysql驱动的位置 这个是MySQL连接的jar包，你需要指定你自己计算机上的jar包的位置-->
       <classPathEntry location="g:\MySQLCon\mysql-connector-java-5.1.38.jar" />
   
       <context id="Tables" targetRuntime="MyBatis3">
   
           <!-- 注释 -->
           <commentGenerator>
               <!-- 是否生成注释代时间戳 -->
               <property name="suppressDate" value="true"/>
               <!-- 是否去除自动生成的注释 true：是 ： false:否 -->
               <property name="suppressAllComments" value="true"/>
           </commentGenerator>
   
           <!-- JDBC连接 其中connectionURL后面的newtest改为你创建的数据库，紧跟在后面是数据库连接的账户和密码-->
           <jdbcConnection
                   driverClass="com.mysql.jdbc.Driver"
                   connectionURL="jdbc:mysql://localhost:3306/newtest"
                   userId="root"
                   password="admin">
           </jdbcConnection>
   
           <!-- 非必需，类型处理器，在数据库类型和java类型之间的转换控制-->
           <!-- 默认false，把JDBC DECIMAL 和 NUMERIC 类型解析为 Integer，为 true时把JDBC DECIMAL 和
            NUMERIC 类型解析为java.math.BigDecimal -->
           <javaTypeResolver>
               <!-- 是否使用bigDecimal， false可自动转化以下类型（Long, Integer, Short, etc.） -->
               <property name="forceBigDecimals" value="false" />
           </javaTypeResolver>
   
           <!-- 生成实体类地址 这里需要你改动，其中targetPackage需要根据你自己创建的目录进行改动 -->
           <javaModelGenerator targetPackage="com.example.springbootmybatisgeneratortest.pojo" targetProject="src/main/java">
               <!-- 从数据库返回的值被清理前后的空格 -->
               <property name="trimStrings" value="true" />
               <!-- enableSubPackages:是否让schema作为包的后缀 -->
               <property name="enableSubPackages" value="false" />
           </javaModelGenerator>
   
           <!-- 生成mapper xml文件 这里不需要改动 -->
           <sqlMapGenerator targetPackage="mapper"  targetProject="src/main/resources">
               <!-- enableSubPackages:是否让schema作为包的后缀 -->
               <property name="enableSubPackages" value="false" />
           </sqlMapGenerator>
   
           <!-- 生成mapper xml对应Client   这里需要改动targetPackage，依据你自己的工程-->
           <javaClientGenerator targetPackage="com.example.springbootmybatisgeneratortest.mapper" targetProject="src/main/java" type="XMLMAPPER">
               <!-- enableSubPackages:是否让schema作为包的后缀 -->
               <property name="enableSubPackages" value="false" />
           </javaClientGenerator>
   
           <!-- 配置表信息 -->
           <!-- schema即为数据库名 tableName为对应的数据库表 domainObjectName是要生成的实体类 enable*ByExample
               是否生成 example类 -->
   
           <table schema="newtest" tableName="category"
                  domainObjectName="Category" enableCountByExample="true"
                  enableDeleteByExample="true" enableSelectByExample="true"
                  enableUpdateByExample="true">
           </table>
   
           <table schema="newtest" tableName="product"
                  domainObjectName="Product" enableCountByExample="true"
                  enableDeleteByExample="true" enableSelectByExample="true"
                  enableUpdateByExample="true">
           </table>
       </context>
   </generatorConfiguration>
   ```

4. 然后使用maven配置生成代码。（这里需要使用maven的命令行）。 
   命令行是**mybatis-generator:generate -e ** 
   在IntelliJ IDEA中的操作步骤如下： 
   首先选择Run->Edit Configurations.. 
   然后点击左上角的“+”号，选择Maven 
   最后在Working directory中填入你项目的根目录，然后在下面的Command line中填入**mybatis-generator:generate -e**。点击OK即可。 

   如下图所示：

   ![maven](C:\Users\Administrator\Desktop\笔记\image\20180202153927825.png)

   然后运行，就可以生成代码了。

5. 在application.yml文件中添加mybatis的配置。

   ```yaml
   spring:
     datasource:
       driver-class-name: com.mysql.jdbc.Driver
       url: jdbc:mysql://127.0.0.1:3306/newtest
       username: root
       password: admin
   mybatis:
     mapper-locations: classpath:mapper/*.xml
     type-aliases-package: com.example.springbootmybatisgeneratortest.pojo
   server:
     port: 8081
   ```



参考资料：https://blog.csdn.net/m0_37884977/article/details/79240950
