@include('layouts.top')

    <div class="container">

      <!--
      <div class="row">
        <div class="col-sm-12">
          <h1 class="blog-title">Blog</h1>
          <p class="lead">Description...</p>
        </div>
      </div>
      -->

      <div class="row">

@yield('content')

      <div class="col-md-3 col-md-offset-1 blog-sidebar">
          <div class="sidebar-module sidebar-module-inset">
            <form action="/blog/search" method="GET">
              <div class="input-group">
                <input id="blog-search-field" type="text" name="query" class="form-control" placeholder="Search for...">
                <span class="input-group-btn">
                  <button id="blog-search" class="btn btn-default" aria-label="search" value="Submit"><span class="glyphicon glyphicon-search" aria-hidden="true"></span></button>
                </span>
              </div><!-- /input-group -->
            </form>
          </div>
          <div class="sidebar-module">
            <h4>About</h4>
            <p>Etiam porta <em>sem malesuada magna</em> mollis euismod. Cras mattis consectetur purus sit amet fermentum. Aenean lacinia bibendum nulla sed consectetur.</p>
          </div>
          <div class="sidebar-module">
            <h4>Languages</h4>
            <ol class="list-unstyled">
              <li><a href="/blog/language/language">Language</a></li>
            </ol>
          </div>
          <div class="sidebar-module">
            <h4>Categories</h4>
            <ol class="list-unstyled">
              <li><a href="/blog/category/category">Category</a></li>
            </ol>
          </div>
          <div class="sidebar-module">
            <h4>Tags</h4>
            <ol class="list-unstyled">
              <li><a href="/blog/tag/tag">Tag</a></li>
            </ol>
          </div>
          <div class="sidebar-module">
            <h4>Archives</h4>
            <ol class="list-unstyled">
              <li><a href="/blog/2015/06">June 2015</a></li>
              <li><a href="/blog/2015/05">May 2015</a></li>
              <li><a href="/blog">More...</a></li>
            </ol>
          </div>
        </div><!-- /.blog-sidebar -->

      </div><!-- /.row -->

    </div><!-- /.container -->

@include('layouts.bottom')
