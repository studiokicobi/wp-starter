<?php
/**
 * Title: Section — Hero
 * Slug: wp-starter/section-hero
 * Categories: featured, banner
 * Description: Homepage hero section. Full-bleed cover with heading, supporting copy, and a CTA.
 * Keywords: hero, banner, intro
 * Viewport Width: 1280
 *
 * @package wp-starter
 *
 * Cover-block a11y note: `backgroundColor` is set in addition to `overlayColor`
 * so the preset class lands on the wrapper itself, not just the positioned
 * overlay span. Pa11y (and most static contrast checkers) can't see colors
 * applied to absolutely-positioned sibling elements, so without this the
 * heading trips a false 1:1 contrast reading during `npm run verify`.
 */

?>
<!-- wp:cover {"isUserOverlayColor":true,"overlayColor":"primary","backgroundColor":"primary","minHeight":60,"minHeightUnit":"vh","align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|80","right":"var:preset|spacing|40","bottom":"var:preset|spacing|80","left":"var:preset|spacing|40"}}}} -->
<div class="wp-block-cover alignfull has-primary-background-color has-background-color has-background" style="padding-top:var(--wp--preset--spacing--80);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--80);padding-left:var(--wp--preset--spacing--40);min-height:60vh">
	<span aria-hidden="true" class="wp-block-cover__background has-background-dim-100 has-primary-background-color has-background-dim"></span>
	<div class="wp-block-cover__inner-container">
		<!-- wp:heading {"textAlign":"center","level":1,"textColor":"background"} -->
		<h1 class="wp-block-heading has-text-align-center has-background-color has-text-color"><?php echo esc_html__( 'A headline that sets the tone', 'wp-starter' ); ?></h1>
		<!-- /wp:heading -->

		<!-- wp:paragraph {"align":"center","textColor":"background","fontSize":"medium"} -->
		<p class="has-text-align-center has-background-color has-text-color has-medium-font-size"><?php echo esc_html__( 'One supporting sentence that earns the click.', 'wp-starter' ); ?></p>
		<!-- /wp:paragraph -->

		<!-- wp:buttons {"layout":{"type":"flex","justifyContent":"center"}} -->
		<div class="wp-block-buttons">
			<!-- wp:button -->
			<div class="wp-block-button"><a class="wp-block-button__link wp-element-button" href="#"><?php echo esc_html__( 'Get started', 'wp-starter' ); ?></a></div>
			<!-- /wp:button -->
		</div>
		<!-- /wp:buttons -->
	</div>
</div>
<!-- /wp:cover -->
