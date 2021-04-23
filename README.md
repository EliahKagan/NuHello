<!--
  Copyright (c) 2021 Eliah Kagan

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
  REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
  AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
  INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
  LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
  OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
  PERFORMANCE OF THIS SOFTWARE.
-->

# NuHello - a NuGet package demonstration

**NuHello** is an example &ldquo;hello world&rdquo; repository and package. Its
purpose is to demonstrate how to do a few things with [NuGet](https://en.wikipedia.org/wiki/NuGet):

- A NuGet package described in a SDK-style `.csproj` (with no `.nuspec`).
- Deployment to a local NuGet package source with `nuget.exe`.
- A NuGet package that just delivers `contentFiles` (and no DLLs), using
  `.nuspec` and `.target` files.
- Per-project local package sources in SDK-style projects (with the `dotnet`
  CLI).
- Adding local package sources in LINQPad.
- Manually editing NuGet package dependencies in LINQPad queries (in the XML
  header of a `.linq` file).

NuHello is [licensed](LICENSE) under the
[0BSD](https://spdx.org/licenses/0BSD.html) (&ldquo;Zero-Clause BSD
License&rdquo;), which is a [&ldquo;public-domain
equivalent&rdquo;](https://en.wikipedia.org/wiki/Public-domain-equivalent_license)
license.

That applies to all files in this repository, including this README file. The
code in this repository also has some outside dependencies&mdash;mainly
[xUnit](https://xunit.net/)&mdash; which are retrieved automatically as needed.
Those outside dependencies are covered by other licenses.

---

The NuGet topics covered in this repository are covered below.

## Microsoft&rsquo;s NuGet Documentation

Although this repository and README cover some aspects of common use, they
focus on some uncommon use cases (and cover those only incompletely). So this
is no substitute for [Microsoft&rsquo;s official NuGet
documentation](https://docs.microsoft.com/en-us/nuget/), which is pretty
detailed.

## nuget.exe

Some of the steps, if you follow them as described below, use `nuget.exe`.
Since most ordinary NuGet package creation, deployment, and use is done from
the `dotnet` CLI these days (or from Visual Studio), you very well may not have
`nuget.exe` installed.

[Microsoft&rsquo;s
instructions](https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools#nugetexe-cli)
detail how to install it. If you&rsquo;re using Windows, another way to install
`nuget.exe` is with the [`scoop`](https://scoop.sh/) package manager:

```powershell
scoop install nuget
```

Once installed, it can be run as `nuget`. Running `nuget` with no arguments
causes it to print a list of actions (much as `dotnet` and other utilities do).

## Clearing the local NuGet cache

Even when you use a local NuGet package source, NuGet packages that you have
installed in projects, such as by adding the package with `dotnet package add`
or by restoring a project the package has been added to with `dotnet restore`,
are locally cached.

This cache is separate from your local package source.

Normally this is no problem, since when a new version of a package is released
(to any package source, remote or local), the developer gives it a different
version number than that package has ever used before. Then, when you specify
that version number, the cached package is not used, since its version number
doesn&rsquo;t match.

However, __when you are experimenting with making and locally deploying NuGet
packages__, you may create, locally deploy, and then use projects that depend
on those packages. In this case, if you deploy a newer &ldquo;version&rdquo; of
the package to your local package source&mdash;something you&rsquo;d never do
with a remote source, or even a local one that another developer was using
(such as over a network share)&mdash;the cached version may continue to be
used.

You can avoid this by removing it from your local cache. The easiest way to do
this is just to clear your cache entirely. Usually this is no problem because
running a restore in a project, which is usually done automatically when
needed, will cause any missing packages to be retrieved again.

Please note that this doesn&rsquo;t just locally cached packages from local
NuGet package sources, but also locally cached packages from remote NuGet
package sources such as [nuget.org](https://www.nuget.org/):

```powershell
dotnet nuget locals all --clear
```

See the [dotnet nuget locals
documentation](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-nuget-locals)
for details.

(N.B. Counterintuitively, `dotnet clean` may break in a project after doing
this. Assuming the packages are still available, you can run `dotnet restore`
and then `dotnet clean` works again. Other `dotnet` CLI actions that may
require a restore, such as `dotnet build`, will take care of doing the restore,
so you don&rsquo;t have to run `dotnet restore` manually before running
`dotnet build`, even if you&rsquo;ve just cleared your local NuGet caches.)

## src/Hello &ndash; Ekgn.NuHello

The NuGet package `Ekgn.NuHello`, generated from the project
`src/Hello/Hello.csproj`, is a very simple library, consisting of a static
class with a public static property. It is described in an SDK-style `.csproj`
file (`Hello.csproj`).

No `.nuspec` file is required because the package is fully described in the
`.csproj` file and generated by running `dotnet build`. The reason you need not
run `dotnet pack` in this case (though you can) is that `Hello.csproj`
contains:

```xml
    <GeneratePackageOnBuild>true</GeneratePackageOnBuild>
```

Although the package is generated on build, I have not set up an automatic
build action to deploy this. (You would not usually want to do that, at least
if you are not using continuous integration and continuous deployment, and
perhaps not even then. The build might succeed but give an unsuitable result.
Furthermore, one often builds during the course of development, when the code
is in no condition to be deployed.)

To build the project, generate the `Ekgn.NuHello` NuGet pacakge, and deploy the
package to a local package source in the `publish` directory, you can run the
following commands. The initial `cd` command assumes you&rsquo;re starting out
from the top-level directory of the working tree (the `NuHello` directory,
unless you named it something else when you cloned the repository).

```powershell
cd src\Hello
dotnet build
nuget add .\bin\Debug\Ekgn.NuHello.1.0.0.nupkg -source ..\..\publish
```

## test/Hello.Test

The `test/Hello.Test` directory contains `Hello.Test.csproj`. This is the unit
test for `src/Hello/Hello.csproj`. It depends directly on that project, rather
than using it through NuGet.

If you wanted to run just that test:

```powershell
cd test\Hello.Test
dotnet test
```

This will, if necessary, build the `Hello.Test` project, as well as the `Hello`
project being tested.

Since this test doesn&rsquo;t use the deployed NuGet package (or any NuGet)
package, it s only a test of the `Hello` project&rsquo;s code.

## test/Hello.NuTest

The `test/Hello.NuTest` directory contains `Hello.NuTest.csproj`. This is like
the unit test `test/Hello.Test/Hello.Test.csproj` described above, except that
this *does* test the locally deployed `Ekgn.NuHello` NuGet package.

If you wanted to run just this test:

```powershell
cd test\Hello.NuTest
dotnet test
```

This builds the test, if necessary. But it neither builds nor deploys a NuGet
package for the `Hello.Test.csproj`. (It does, of course, *retrieve* the
package from the local package source, if necessary. That happens during the
restore operation.)

You don&rsquo;t have to modify any configuration for the local package source
to be used, because the project has a `NuGet.Config` file that specifies it.

## test/Hello-nutest.linq

`test/Hello-nutest.linq` is a [LINQPad](https://www.linqpad.net/) query that
tests (or, really, *demonstrates*) `Ekgn.NuHello`. To run it successfully, you
must configure LINQPad to use the local NuGet package source. As far as I know,
LINQPad does not support custom per-query NuGet sources.

To do this in LINQPad:

1. Press <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>M</kbd> or go to
   *Query > NuGet Package Manager*.
2. If you&rsquo;re running a non-paid version of LINQPad, you&rsquo;ll see a
   message about limited NuGet search functionality within LINQPad.
   That&rsquo;sno problem.
3. At the bottom of the *LINQPad NuGet Manager* window, there is a drop-down
   menu, in which &ldquo;NuGet 3 official package source&rdquo; is most likely
   selected. Click that drop-down menu and select &ldquo;(configure
   sources&hellip;)&rdquo;.
4. In the *NuGet Settings* dialog, in &ldquo;Package Sources&rdquo; tab, near
   the bottom, put in any name you like for &ldquo;Name&rdquo; and the full
   (absolute) path to the local NuGet package source directory in
   &ldquo;Source&rdquo;. (You can select the source by clicking the
   &ldquo;&hellip;&rdquo; button and navigating to it in a file picker dialog.)
5. Click &ldquo;Save&rdquo;. It&rsquo;s fine for the local package source to
   be listed under the official remote one (unless someone publishes a
   different package, also called `Ekgn.NuHello`, to nuget.org).
6. Click &ldquo;OK&rdquo;.
7. Click &ldquo;Close&rdquo; to leave the *LINQPad NuGet Manager* window. The
   query file already has the necessary NuGet dependency set up.

Then, assuming the package is deployed to the local package source, it should be found, and the LINQPad query, when run, should output:

```none
Hello, world!
```

To see how the dependency is specified in the LINQPad query, open the query file `Hello-nutest.linq` in a text editor. This lets you see its XML header:

```xml
<Query Kind="Statements">
  <NuGetReference Version="1.0.0">Ekgn.NuHello</NuGetReference>
</Query>
```

## src/Goodbye &ndash; Ekgn.NuHello.Goodbye

The NuGet package `Ekgn.NuHello.Goodbye`, generated from the directory
`src/Goodbye` (using `Ekgn.NuHello.Goodbye.nuspec`), is not even a library.
There is no managed or native source code in this directory. The resulting
package does not even contain a DLL or any other binary file, though most of
the time you&rsquo;d use this technique, it would be to deliver a native DLL.

This is a simple demonstration of `contentFiles`, a mechanism for delivering
additional files to projects that depend in a package, *other* than DLLs (and
files that support them) built from source code in the package.

When a project depends on `Ekgn.NuHello.Goodbye`, and you build that project,
the file `contentFiles/any/any/message.txt` is delivered to the build output
directory.

The usual use for this technique is to deliver DLLs, usually native DLLs, that
are not built as part of a project. It is only occasionally useful.

To build the `Ekgn.NuHello.Goodbye` NuGet package and deploy it to the local
package source, you can run these commands:

```powershell
cd src\Goodbye
nuget pack
nuget add Ekgn.NuHello.Goodbye.1.0.0.nupkg -source ..\..\publish
```

## test/Goodbye.NuTest

The `test/Goodbye.NuTest` directory contains `Goodbye.NuTest.csproj`. This
tests the locally deployed `Ekgn.NuHello.Goodbye` NuGet package.

If you wanted to run just this test:

```powershell
cd test\Goodbye.NuTest
dotnet test
```

This builds the test, if necessary. But it neither packs nor deploys the
`Ekgn.NuHello.Goodbye` NuGet package from `src/Goodbye`. (Like
`test/Hello.NuTest`, it does *retrieve* the package from the local package
source, if necessary, during the restore operation.)

The `Nuget.Config` file specifies the local package source, so (as with
`test/Hello.NuTest`) you need not modify any global configuration.

The test code opens the file `message.txt`, which `Ekgn.NuHello.Goodbye` causes
to be delivered to the test project&rsquo;s build output directory, and ensures
it has the anticipated contents.

Usually, if one uses the `contentFiles` technique detailed above, one delivers
one or more DLLs. In this case, a text file is delivered. This would not be
very useful, and might even be inconvenient to access, by an ordinary program,
because `dotnet run` uses the directory it is run from as the current
directory. But unit tests, at least with xUnit, are run from the build output
directory, so `message.txt` is found.
