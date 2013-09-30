//
//  SDAViewController.m
//  Sudoku.v1
//
//  Created by SDA on 9/6/13.
//  Copyright (c) 2013 Sean Adler. All rights reserved.
//

#import "SudokuViewController.h"
#import "SudokuGridModel.h"
#import "SudokuNumpadModel.h"
//#import "SudokuGrid.h"
#import "SudokuNumpad.h"
#import "SudokuTile.h"


#define xInset 0
#define yInset 10

typedef NS_ENUM(NSUInteger, LastTilePressedType) {
    GRID,
    NUM_PAD
};


@interface SudokuViewController ()

@property (nonatomic, strong) SudokuGridModel *gridModel;
@property (nonatomic, strong) SudokuNumpadModel *numpadModel;
@property (nonatomic) LastTilePressedType lastTilePressed;
@property (nonatomic, strong) NSString *highlightTileStr;
@property (nonatomic, strong) UIButton *resetButton;

@end

@implementation SudokuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Instantiate models
    self.gridModel = [[SudokuGridModel alloc] init];
    self.numpadModel = [[SudokuNumpadModel alloc] init];
    
    // Set other properties
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Create frame for grid.
    int originX = self.view.bounds.size.width * .10;
    int originY = self.view.bounds.size.height * .10;
    int size = MIN(self.view.bounds.size.width, self.view.bounds.size.height) * .6;
    CGRect gridFrame = CGRectMake(originX, originY, size, size);
    
    
    // Create grid.
    self.grid = [[SudokuGrid alloc] initWithFrame:gridFrame];
    
    
    // Tell grid view to draw itself using grid model
    [self.grid drawButtonsUsingArray:self.gridModel.gridNumbers];
    
    
    // Set up delegation so touch events propagate back up to this controller
    self.grid.delegate = self;
    [self.view addSubview:self.grid];
    
    
    // Create numpad.
    CGRect numpadFrame = CGRectMake(originX, originY+size+30, size, .80*originX);
    self.numpad = [[SudokuNumpad alloc] initWithFrame:numpadFrame];
    [self.numpad drawButtonsUsingArray:self.numpadModel.numpadNumbers];
    
    
    // Numpad also needs delegation for touch events.
    self.numpad.delegate = self;
    [self.view addSubview:self.numpad];
    
    // Add reset button.
    CGRect resetButtonFrame = CGRectMake(50, 100, 20, 20);
    self.resetButton = [[UIButton alloc] initWithFrame:resetButtonFrame];
    self.resetButton.backgroundColor = [UIColor whiteColor];
    self.resetButton.titleLabel.text = @"RESET";
    [self.resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}


// updateUI:  handles all UI logic for views based on model data.
- (void)updateUI
{
    for (int i = 0; i < self.gridModel.gridNumbers.count; i++) {
        [self.grid setTileAtIndex:i
                          toValue:self.gridModel.gridNumbers[i]
                         editable:[self.gridModel.gridNumbersEditable[i] boolValue]];
    }
    
    [self.grid highlightTiles:self.highlightTileStr];
}


// gridTilePressedAtIndex:  sets model properties and calls updateUI:
- (void)gridTilePressedAtIndex:(NSUInteger)tileIndex
{
    NSString *newTileString = self.gridModel.gridNumbers[tileIndex];
    
    [self.numpad highlightTile:nil];

    if ([self.gridModel.gridNumbersEditable[tileIndex] boolValue]
          && (self.lastTilePressed == NUM_PAD)) {
            // Place a tile
        if ([self.gridModel validTile:self.numpadModel.selectedTile forIndex:tileIndex]) {
            
            self.gridModel.gridNumbers[tileIndex] = self.numpadModel.selectedTile;
            self.gridModel.selectedTile = newTileString;
            self.gridModel.selectedTileIndex = tileIndex;
            self.highlightTileStr = nil;
            
        } else {
            NSLog(@"Not a legal move.");
            [self.grid flashRedAtIndex:tileIndex];
            // invalid tile placement
            // TODO -- flash red
            return;
        }

    } else {
    
        self.highlightTileStr = newTileString;
        self.gridModel.selectedTileIndex = tileIndex;
    }
    
    self.lastTilePressed = GRID;
    [self updateUI];
    
    NSLog(@"Grid tile %@ pressed at index %d.\n",
          self.gridModel.gridNumbers[self.gridModel.selectedTileIndex], tileIndex);
}


- (void)numpadTilePressedAtIndex:(NSUInteger)tileIndex
{
    NSLog(@"Numpad tile %@ pressed at index %d.\n",
          self.numpadModel.numpadNumbers[tileIndex], tileIndex);
    
    self.highlightTileStr = self.numpadModel.numpadNumbers[tileIndex];
    self.numpadModel.tileIsSelected = YES;
    self.numpadModel.selectedTile = [self.numpadModel.numpadNumbers objectAtIndex:tileIndex];
    
    [self.numpad highlightTile:self.numpadModel.selectedTile];
    self.lastTilePressed = NUM_PAD;
    [self updateUI];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
