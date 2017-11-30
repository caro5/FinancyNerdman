class WordpressController < ApplicationController
  include WordpressApi

  DEFAULT_CATEGORY_SIZE = 5

  def categories
    categories = WordpressApi::get_categories(wordpress_params)
    if categories.length == 1
      category = categories.first
      posts = WordpressApi::get_posts_by_category(
        category_slug: category['slug'],
        post_size: wordpress_params[:post_size]
      )

      args = {
        posts: posts.map do |post|
          post['title']['rendered']
        end.en.conjunction(article: false)
      }

      render json: {
        speech: ApiResponse.get_response(:posts, args)
      }
    else
      args = {
        category: wordpress_params[:post_category],
        categories: categories.sample(DEFAULT_CATEGORY_SIZE)
          .map { |category| category['name'] }.en.conjunction(article: false)
      }
      render json: {
        speech: ApiResponse.get_response(:categories, args)
      }
    end
  end

  def product
    product = WordpressApi::get_product(wordpress_params.slice(:product)).first
    data = product['nw_review_data']['product_data']['data']

    args = {
      detail_link: data['detail_link'],
      img_source: data['image_source_large'],
      name: product['nw_review_data']['name']
    }

    render json: {
      speech: ApiResponse.get_response(:product, args)
    }
  end

  private

  def wordpress_params
    params.require(:result).require(:parameters).permit(
      :post_size, :post_category, :product
    )
  end
end
