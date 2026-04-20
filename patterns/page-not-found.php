<?php
/**
 * Title: Page Not Found
 * Slug: wp-starter/page-not-found
 * Inserter: no
 * Description: Translatable content for the 404 template.
 *
 * @package wp-starter
 */

?>
<!-- wp:heading {"level":1,"className":"wp-block-post-title"} -->
<h1 class="wp-block-post-title"><?php echo esc_html__( 'Page not found', 'wp-starter' ); ?></h1>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><?php echo esc_html__( 'It looks like nothing was found at this location. Maybe try a search?', 'wp-starter' ); ?></p>
<!-- /wp:paragraph -->

<!-- wp:search {"showLabel":false,"buttonPosition":"button-inside","buttonUseIcon":true} /-->

<!-- wp:spacer -->
<div style="height:100px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->
