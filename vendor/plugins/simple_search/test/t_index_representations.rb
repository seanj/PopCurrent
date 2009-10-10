require File.dirname(__FILE__) + '/test_helper'

class IndexRepresentationTest < Test::Unit::TestCase
  fixtures :pages, :page_authors, :page_paras

  def setup
    @page = Page.find(1)
    @author = PageAuthor.find(1)
    @para = PagePara.find(1)
  end
  
  def test_index_representations
    
    assert_equal "mister Julian", @author.index_repr_of_first_name,
      "First name should have an index_repr"
    
    assert_equal "mister julian tarkhanov friday october 2003", @author.index_repr,
      "First name should use index_repr_of_first_name"
    
    assert_equal "brazil spread time commonterm 1984 takes place \
certain date only know century film begins moreover single setting \
give hint about year part 20th depicted same possible styles fashions \
playing with each other computers that resemble typewriters clothing \
noir cityscapes early casablanca computer screen bwesterns miseenscene \
artificial filled citations references viewer deliberately obstructed \
from locating exact space where happening guards party dressed xviiith \
servicemen police officers troops", @para.index_repr

    for page in Page.find(:all)
      elements = page.index_repr.split(/ /)
      assert elements.find{|el| el.size < 4 }.nil?, "No strings shorter than 4 chars should be present"
      assert elements.find{|el| el =~/[^\w]/ }.nil?, "The strings should contain only word characters"
    end

    assert_equal "mister julian tarkhanov friday october 2003 something \
about postmodern cinema brazil this long text written school brazil spread \
time commonterm 1984 takes place certain date only know century film begins \
moreover single setting give hint year part 20th depicted same possible styles \
fashions playing with each other computers that resemble typewriters clothing noir \
cityscapes early casablanca computer screen bwesterns miseenscene artificial filled \
citations references viewer deliberately obstructed from locating exact space where \
happening guards party dressed xviiith servicemen police officers troops what special \
whole concept importance information this essence deeply ministry love busy cultivating \
brother collecting managing such apparent meaning goal metaministry sense within itself \
contains torture chambers transport department transit records security tasks connected \
protagonists quest might seem finding jill instead __information her__ more than system \
people represented person killed during recorded excised deleted inoperative effectively \
becoming reference", @page.index_repr    
  end
end