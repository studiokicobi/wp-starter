<?php
/**
 * Title: Section — Writing
 * Slug: wp-starter/section-writing
 * Categories: featured, query
 * Description: Latest posts teaser for the homepage. Uses core/query in its default, token-driven form.
 * Keywords: writing, blog, posts, query
 * Viewport Width: 1280
 *
 * @package wp-starter
 */

?>
<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|70","bottom":"var:preset|spacing|70","right":"var:preset|spacing|40","left":"var:preset|spacing|40"}}},"layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull" style="padding-top:var(--wp--preset--spacing--70);padding-right:var(--wp--preset--spacing--40);padding-bottom:var(--wp--preset--spacing--70);padding-left:var(--wp--preset--spacing--40)">
	<!-- wp:heading {"level":2} -->
	<h2 class="wp-block-heading"><?php echo esc_html__( 'Writing', 'wp-starter' ); ?></h2>
	<!-- /wp:heading -->

	<!-- wp:query {"queryId":0,"query":{"perPage":3,"pages":0,"offset":0,"postType":"post","order":"desc","orderBy":"date","inherit":false},"align":"wide"} -->
	<div class="wp-block-query alignwide">
		<!-- wp:post-template -->
			<!-- wp:post-title {"isLink":true,"level":3} /-->
			<!-- wp:post-excerpt /-->
			<!-- wp:post-date /-->
		<!-- /wp:post-template -->
	</div>
	<!-- /wp:query -->
</div>
<!-- /wp:group -->
