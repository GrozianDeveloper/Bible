//
//  BibleViewController+PageHandle.swift
//  Bible
//
//  Created by Bogdan Grozian on 28.02.2022.
//

import UIKit

// MARK: - UIPageViewControllerDelegate
extension BibleViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updateActiveChapterOffset()
    }
}

// MARK: - UIPageViewControllerDataSource
extension BibleViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! ChapterViewController), index > 0 else  { return nil }
        let previous = pages[index - 1]
        return previous
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController as! ChapterViewController), index < pages.count - 1 else  { return nil }
        let next = pages[index + 1]
        return next
    }
}

// MARK: Support
extension BibleViewController {
    private func updateActiveChapterOffset() {
        guard let chapterController = bookViewController.viewControllers?.first as? ChapterViewController else {
            return
        }
        activeChapterOffset = chapterController.chapterOffset
    }
}
