<?php
/**
 * Title: Hero
 * Slug: wp-starter/hero
 * Categories: featured, banner
 * Description: Full-width hero with heading, supporting copy, and a call-to-action.
 * Keywords: hero, banner, intro
 * Viewport Width: 1280
 *
 * @package wp-starter
 */

?>
<!-- wp:cover {"isUserOverlayColor":true,"customOverlayColor":"var:preset|color|secondary","minHeight":60,"minHeightUnit":"vh","align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|80","right":"var:preset|spacing|40","bottom":"var:preset|spacing|80","left":"var:preset|spacing|40"}}}} -->
<div class="wp-block-cover alignfull" style="padding-top:var(--wp--preset--spacing--80);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--80);padding-left:var(--wp--preset--spacing--40);min-height:60vh">
	<span aria-hidden="true" class="wp-block-cover__background has-background-dim-100 has-background-dim" style="background-color:var(--wp--preset--color--secondary)"></span>
	<div class="wp-block-cover__inner-container">
		<!-- wp:heading {"textAlign":"center","level":1,"textColor":"white"} -->
		<h1 class="wp-block-heading has-text-align-center has-white-color has-text-color"><?php echo esc_html__( 'A headline that sets the tone', 'wp-starter' ); ?></h1>
		<!-- /wp:heading -->

		<!-- wp:paragraph {"align":"center","textColor":"white","fontSize":"medium"} -->
		<p class="has-text-align-center has-white-color has-text-color has-medium-font-size"><?php echo esc_html__( 'One supporting sentence that earns the click.', 'wp-starter' ); ?></p>
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
