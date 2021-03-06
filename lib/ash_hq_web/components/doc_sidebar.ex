defmodule AshHqWeb.Components.DocSidebar do
  use Surface.Component

  alias AshHqWeb.Routes
  alias Surface.Components.LivePatch

  prop class, :css_class, default: ""
  prop libraries, :list, required: true
  prop extension, :any, default: nil
  prop guide, :any, default: nil
  prop library, :any, default: nil
  prop library_version, :any, default: nil
  prop selected_versions, :map, default: %{}
  prop id, :string, required: true
  prop dsl, :any, required: true
  prop module, :any, required: true
  prop sidebar_state, :map, required: true
  prop collapse_sidebar, :event, required: true
  prop expand_sidebar, :event, required: true

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <aside id={@id} class={"grid w-64 h-full overflow-y-scroll pb-36", @class} aria-label="Sidebar">
      <div class="py-3 px-3">
        <ul class="space-y-2">
          {#for library <- @libraries}
            <li>
              <LivePatch
                to={Routes.library_link(library, selected_version_name(library, @selected_versions))}
                class={
                  "flex items-center p-2 text-base font-normal text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700",
                  "dark:bg-gray-600": !@module && !@guide && !@extension && @library && library.id == @library.id
                }
              >
                <Heroicons.Outline.CollectionIcon class="w-6 h-6" />
                <span class="ml-3 mr-2">{library.display_name}</span>
                <span class="font-light text-gray-500">{selected_version_name(library, @selected_versions)}</span>
              </LivePatch>
              {#if @library && @library_version && library.id == @library.id}
                {#for {category, guides} <- guides_by_category(@library_version.guides)}
                  <div class="ml-2 text-gray-500">
                    {category}
                  </div>
                  {#for guide <- guides}
                    <li class="ml-3">
                      <LivePatch
                        to={Routes.doc_link(guide, @selected_versions)}
                        class={
                          "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                          "dark:bg-gray-600": @guide && @guide.id == guide.id
                        }
                      >
                        <Heroicons.Outline.BookOpenIcon class="h-4 w-4" />
                        <span class="ml-3 mr-2">{guide.name}</span>
                      </LivePatch>
                    </li>
                  {/for}
                {/for}

                {#if !Enum.empty?(@library_version.guides)}
                  <div class="ml-2 text-gray-500">
                    Extensions
                  </div>
                {/if}
                {#for extension <- get_extensions(library, @selected_versions)}
                  <li class="ml-3">
                    <LivePatch
                      to={Routes.doc_link(extension, @selected_versions)}
                      class={
                        "flex items-center p-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                        "dark:bg-gray-600": @extension && @extension.id == extension.id
                      }
                    >
                      <span class="ml-3 mr-2">{extension.name}</span>
                      {render_icon(assigns, extension.type)}
                    </LivePatch>
                    {#if @extension && @extension.id == extension.id && !Enum.empty?(extension.dsls)}
                      {render_dsls(assigns, extension.dsls, [])}
                    {/if}
                  </li>
                {/for}
                {#if !Enum.empty?(@library_version.modules)}
                  <div class="ml-2 text-gray-500">
                    Modules
                  </div>
                  {#for {category, modules} <- modules_and_categories(@library_version.modules)}
                    <div class="ml-4">
                      <span class="text-sm text-gray-900 dark:text-gray-500">{category}</span>
                    </div>
                    {#for module <- modules}
                      <li class="ml-4">
                        <LivePatch
                          to={Routes.doc_link(module, @selected_versions)}
                          class={
                            "flex items-center pt-1 text-base font-normal text-gray-900 rounded-lg dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700",
                            "dark:bg-gray-600": @module && @module.id == module.id
                          }
                        >
                          <span class="ml-3 mr-2">{module.name}</span>
                          <Heroicons.Outline.CodeIcon class="h-4 w-4" />
                        </LivePatch>
                      </li>
                    {/for}
                  {/for}
                {/if}
              {/if}
            </li>
          {/for}
        </ul>
      </div>
    </aside>
    """
  end

  defp modules_and_categories(modules) do
    modules
    |> Enum.group_by(&{&1.category_index, &1.category})
    |> Enum.sort_by(fn {{index, _}, _} ->
      index
    end)
    |> Enum.map(fn {{_, category}, list} ->
      {category, list}
    end)
  end

  defp render_dsls(assigns, dsls, path) do
    ~F"""
    <ul class="ml-1 flex flex-col">
      {#for dsl <- Enum.filter(dsls, &(&1.path == path))}
        <li class="border-l pl-1 border-orange-600 border-opacity-30">
          <div class="flex flex-row items-center">
            {#if Enum.any?(dsls, &List.starts_with?(&1.path, dsl.path ++ [dsl.name]))}
              {#if !(@dsl && List.starts_with?(@dsl.path ++ [@dsl.name], path ++ [dsl.name]))}
                {#if @sidebar_state[dsl.id] == "open"}
                  <button :on-click={@collapse_sidebar} phx-value-id={dsl.id}>
                    <Heroicons.Outline.ChevronDownIcon class="w-3 h-3" />
                  </button>
                {#else}
                  <button :on-click={@expand_sidebar} phx-value-id={dsl.id}>
                    <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
                  </button>
                {/if}
              {/if}
            {/if}
            <LivePatch
              to={Routes.doc_link(dsl, @selected_versions)}
              class={
                "flex items-center p-1 text-base font-normal rounded-lg hover:text-orange-300",
                "text-orange-600 dark:text-orange-400 font-bold": @dsl && @dsl.id == dsl.id
              }
            >
              {dsl.name}
            </LivePatch>
          </div>
          {#if @sidebar_state[dsl.id] == "open" ||
              (@dsl && List.starts_with?(@dsl.path ++ [@dsl.name], path ++ [dsl.name]))}
            {render_dsls(assigns, dsls, path ++ [dsl.name])}
          {/if}
        </li>
      {/for}
    </ul>
    """
  end

  def render_icon(assigns, "Resource") do
    ~F"""
    <Heroicons.Outline.ServerIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Api") do
    ~F"""
    <Heroicons.Outline.SwitchHorizontalIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "DataLayer") do
    ~F"""
    <Heroicons.Outline.DatabaseIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Flow") do
    ~F"""
    <Heroicons.Outline.MapIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Notifier") do
    ~F"""
    <Heroicons.Outline.MailIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, "Registry") do
    ~F"""
    <Heroicons.Outline.ViewListIcon class="h-4 w-4" />
    """
  end

  def render_icon(assigns, _) do
    ~F"""
    <Heroicons.Outline.PuzzleIcon class="h-4 w-4" />
    """
  end

  defp guides_by_category(guides) do
    guides
    |> Enum.group_by(& &1.category)
    |> Enum.sort_by(fn {category, _guides} ->
      Enum.find_index(["Tutorials", "Topics", "How To", "Misc"], &(&1 == category)) || :infinity
    end)
    |> Enum.map(fn {category, guides} ->
      {category, Enum.sort_by(guides, & &1.order)}
    end)
  end

  defp selected_version_name(library, selected_versions) do
    if (selected_versions[library.id] || "latest") == "latest" do
      "latest"
    else
      Enum.find_value(library.versions, fn version ->
        version.version

        if version.id == selected_versions[library.id] do
          version.version
        end
      end)
    end
  end

  defp get_extensions(library, selected_versions) do
    case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
      nil ->
        []

      version ->
        version.extensions
    end
  end
end
