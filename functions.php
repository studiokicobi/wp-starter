<?php
/**
 * WP Starter theme functions.
 *
 * @package wp-starter
 */

if ( ! function_exists( 'wp_starter_theme_support' ) ) {
	/**
	 * General Theme Settings.
	 *
	 * @since v1.0
	 *
	 * @return void
	 */
	function wp_starter_theme_support() {
		// Make theme available for translation: Translations can be filed in the /languages/ directory.
		load_theme_textdomain( 'wp-starter', __DIR__ . '/languages' );

		// Add support for Post thumbnails.
		add_theme_support( 'post-thumbnails' );
		// Add support for responsive embedded content.
		add_theme_support( 'responsive-embeds' );
		// Add support for Block Styles.
		add_theme_support( 'wp-block-styles' );
	}
	add_action( 'after_setup_theme', 'wp_starter_theme_support' );

	// Disable Block Directory. See https://github.com/WordPress/gutenberg/blob/trunk/docs/reference-guides/filters/editor-filters.md#block-directory.
	remove_action( 'enqueue_block_editor_assets', 'wp_enqueue_editor_block_directory_assets' );
	remove_action( 'enqueue_block_editor_assets', 'gutenberg_enqueue_block_editor_assets_block_directory' );
}

if ( ! function_exists( 'wp_starter_register_block_styles' ) ) {
	/**
	 * Register block style variations.
	 *
	 * The `section` variation on core/group hoists the shared
	 * top/bottom/horizontal padding used by every homepage section
	 * (cards, writing, cta). Patterns opt in with
	 * `"className":"is-style-section"`.
	 *
	 * @return void
	 */
	function wp_starter_register_block_styles() {
		register_block_style(
			'core/group',
			array(
				'name'  => 'section',
				'label' => __( 'Section', 'wp-starter' ),
			)
		);
	}
	add_action( 'init', 'wp_starter_register_block_styles' );
}

if ( ! function_exists( 'wp_starter_get_main_asset_data' ) ) {
	/**
	 * Get the dependency and version metadata for the compiled main bundle.
	 *
	 * @return array{dependencies: array<int, string>, version: string}
	 */
	function wp_starter_get_main_asset_data() {
		$theme_version = wp_get_theme()->get( 'Version' );
		$asset_file    = get_theme_file_path( 'build/main.asset.php' );

		if ( ! file_exists( $asset_file ) ) {
			return array(
				'dependencies' => array(),
				'version'      => $theme_version,
			);
		}

		$asset_data = require $asset_file;

		if ( ! is_array( $asset_data ) ) {
			return array(
				'dependencies' => array(),
				'version'      => $theme_version,
			);
		}

		return array(
			'dependencies' => isset( $asset_data['dependencies'] ) && is_array( $asset_data['dependencies'] ) ? $asset_data['dependencies'] : array(),
			'version'      => isset( $asset_data['version'] ) && is_string( $asset_data['version'] ) ? $asset_data['version'] : $theme_version,
		);
	}
}

if ( ! function_exists( 'wp_starter_load_scripts' ) ) {
	/**
	 * Enqueue CSS Stylesheets and Javascript files.
	 *
	 * @return void
	 */
	function wp_starter_load_scripts() {
		$theme_version = wp_get_theme()->get( 'Version' );
		$asset_data    = wp_starter_get_main_asset_data();
		$style_handle  = 'wp-starter-style';
		$main_handle   = 'wp-starter-main';
		$script_handle = 'wp-starter-script';

		// 1. Styles.
		wp_enqueue_style( $style_handle, get_stylesheet_uri(), array(), $theme_version );
		wp_enqueue_style( $main_handle, get_theme_file_uri( 'build/main.css' ), array( $style_handle ), $asset_data['version'], 'all' ); // main.scss: Compiled custom styles.
		wp_style_add_data( $main_handle, 'rtl', 'replace' );

		// 2. Scripts.
		wp_enqueue_script( $script_handle, get_theme_file_uri( 'build/main.js' ), $asset_data['dependencies'], $asset_data['version'], true );
	}
	add_action( 'wp_enqueue_scripts', 'wp_starter_load_scripts' );
}
