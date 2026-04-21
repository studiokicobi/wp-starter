<?php
/**
 * Title: A11y — Skip Link
 * Slug: wp-starter/a11y-skip-link
 * Inserter: no
 * Description: Focusable skip-to-main-content link. Include at the top of every template, directly above the header template part.
 *
 * @package wp-starter
 */

?>
<!-- wp:html -->
<a class="screen-reader-text skip-link" href="#wp--skip-link--target">
	<?php echo esc_html__( 'Skip to main content', 'wp-starter' ); ?>
</a>
<!-- /wp:html -->
