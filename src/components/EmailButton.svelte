<script>
  import { fly, fade } from "svelte/transition";

  let clicked = $state(false);
  let notification = $state(false);

  $effect(() => {
    if (notification) {
      const timeout = setTimeout(() => {
        notification = false;
      }, 1500);

      return () => clearTimeout(timeout);
    }
  });

  let mouseLeaveTimeout = $state(null);
  function onMouseLeave() {
    if (mouseLeaveTimeout) {
      clearTimeout(mouseLeaveTimeout);
    }
    mouseLeaveTimeout = setTimeout(() => {
      clicked = false;
    }, 1500);
  }
</script>

<button
  class="w-30 btn btn-accent select-text inline-grid grid-cols-1 grid-rows-1 place-items-center"
  onclick={() => {
    navigator.clipboard.writeText("elena@elena.sh");
    clicked = true;
    notification = true;
  }}
  onmouseleave={onMouseLeave}
>
  {#key clicked}
    <span
      transition:fade={{ duration: 200 }}
      class="col-start-1 row-start-1 flex items-center gap-1 text-nowrap"
    >
      {#if !clicked}
        Contact Me :)
      {:else}
        <code class="bg-black/10 px-1 rounded">elena@elena.sh</code>
      {/if}
    </span>
  {/key}
</button>

{#if notification}
  <div class="toast" transition:fly={{ y: 20, duration: 300 }}>
    <span
      class="alert bg-accent text-black font-bold flex flex-nowrap items-center"
    >
      Copied email to clipboard
      <!-- cipboard saved icon -->
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-6 w-6"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"
        />
      </svg>
    </span>
  </div>
{/if}
